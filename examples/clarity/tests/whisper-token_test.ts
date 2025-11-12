import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.7.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that token has correct name and symbol",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'get-name', [], deployer.address),
            Tx.contractCall('whisper-token', 'get-symbol', [], deployer.address),
            Tx.contractCall('whisper-token', 'get-decimals', [], deployer.address),
        ]);

        block.receipts[0].result.expectOk().expectAscii('WhisperToken');
        block.receipts[1].result.expectOk().expectAscii('WSPR');
        block.receipts[2].result.expectOk().expectUint(6);
    },
});

Clarinet.test({
    name: "Ensure deployer has initial balance",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'get-balance',
                [types.principal(deployer.address)],
                deployer.address
            ),
            Tx.contractCall('whisper-token', 'get-total-supply', [], deployer.address),
        ]);

        block.receipts[0].result.expectOk().expectUint(1000000000000);
        block.receipts[1].result.expectOk().expectUint(1000000000000);
    },
});

Clarinet.test({
    name: "Test token transfer",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'transfer',
                [
                    types.uint(1000),
                    types.principal(deployer.address),
                    types.principal(wallet1.address),
                    types.none()
                ],
                deployer.address
            ),
        ]);

        block.receipts[0].result.expectOk().expectBool(true);

        // Check balances after transfer
        let checkBlock = chain.mineBlock([
            Tx.contractCall('whisper-token', 'get-balance',
                [types.principal(deployer.address)],
                deployer.address
            ),
            Tx.contractCall('whisper-token', 'get-balance',
                [types.principal(wallet1.address)],
                deployer.address
            ),
        ]);

        checkBlock.receipts[0].result.expectOk().expectUint(999999999000);
        checkBlock.receipts[1].result.expectOk().expectUint(1000);
    },
});

Clarinet.test({
    name: "Test transfer with insufficient balance fails",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'transfer',
                [
                    types.uint(1000),
                    types.principal(wallet1.address),
                    types.principal(wallet2.address),
                    types.none()
                ],
                wallet1.address
            ),
        ]);

        // Should fail because wallet1 has no balance
        block.receipts[0].result.expectErr();
    },
});

Clarinet.test({
    name: "Test minting by owner",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'mint',
                [
                    types.uint(5000),
                    types.principal(wallet1.address)
                ],
                deployer.address
            ),
        ]);

        block.receipts[0].result.expectOk().expectBool(true);

        // Check new balance and total supply
        let checkBlock = chain.mineBlock([
            Tx.contractCall('whisper-token', 'get-balance',
                [types.principal(wallet1.address)],
                deployer.address
            ),
            Tx.contractCall('whisper-token', 'get-total-supply', [], deployer.address),
        ]);

        checkBlock.receipts[0].result.expectOk().expectUint(5000);
        checkBlock.receipts[1].result.expectOk().expectUint(1000000005000);
    },
});

Clarinet.test({
    name: "Test minting by non-owner fails",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'mint',
                [
                    types.uint(5000),
                    types.principal(wallet2.address)
                ],
                wallet1.address
            ),
        ]);

        // Should fail - only owner can mint
        block.receipts[0].result.expectErr().expectUint(100);
    },
});

Clarinet.test({
    name: "Test burning tokens",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'burn',
                [types.uint(1000)],
                deployer.address
            ),
        ]);

        block.receipts[0].result.expectOk().expectBool(true);

        // Check balance and total supply after burn
        let checkBlock = chain.mineBlock([
            Tx.contractCall('whisper-token', 'get-balance',
                [types.principal(deployer.address)],
                deployer.address
            ),
            Tx.contractCall('whisper-token', 'get-total-supply', [], deployer.address),
        ]);

        checkBlock.receipts[0].result.expectOk().expectUint(999999999000);
        checkBlock.receipts[1].result.expectOk().expectUint(999999999000);
    },
});

Clarinet.test({
    name: "Test burning more than balance fails",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;

        let block = chain.mineBlock([
            Tx.contractCall('whisper-token', 'burn',
                [types.uint(1000)],
                wallet1.address
            ),
        ]);

        // Should fail - insufficient balance
        block.receipts[0].result.expectErr().expectUint(102);
    },
});
