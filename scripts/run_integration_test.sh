#!/bin/bash

set -ex

LACONIC_SO=${LACONIC_SO:-laconic-so}

# Build and deploy a cluster with only what we need from the stack
$LACONIC_SO --stack fixturenet-eth-loaded setup-repositories \
    --include cerc-io/go-ethereum,cerc-io/ipld-eth-db

$LACONIC_SO --stack fixturenet-eth-loaded build-containers \
    --include cerc/fixturenet-eth-geth,cerc/fixturenet-eth-lighthouse,cerc/ipld-eth-db

$LACONIC_SO --stack fixturenet-eth-loaded deploy \
    --include fixturenet-eth,ipld-eth-db \
    --cluster test up

# Build and run the deployment server
docker build ./test/contract -t cerc/test-contract

# Read an account key so we can send from a funded account
DEPLOYER_PK="$(docker exec test-fixturenet-eth-geth-1-1 cat /opt/testnet/build/el/accounts.csv | head -n1 | cut -d',' -f3)"

docker run -d --rm -i -p 3000:3000 --network test_default --name=test-contract-deployer \
    -e ETH_ADDR=http://fixturenet-eth-geth-1:8545 \
    -e ETH_CHAIN_ID=1212 \
    -e DEPLOYER_PRIVATE_KEY=$DEPLOYER_PK \
    cerc/test-contract

export PGPASSWORD=password
query_blocks_exist='SELECT exists(SELECT block_number FROM ipld.blocks LIMIT 1);'

until [[ "$(psql -qtA cerc_testing -h localhost -U vdbm -p 8077 -c "$query_blocks_exist")" = 't' ]]; do
    echo "Waiting until we have some data written..."
    sleep 1
done

exec go test -v ./integration
