"""
Tests for Web3Utils
"""

import pytest
from unittest.mock import Mock, patch, MagicMock
from web3 import Web3
from web3_utils import Web3Utils


@pytest.fixture
def mock_w3():
    """Mock Web3 instance"""
    with patch('web3_utils.Web3') as mock:
        w3_instance = Mock()
        w3_instance.is_connected.return_value = True
        w3_instance.eth = Mock()
        mock.return_value = w3_instance
        yield w3_instance


def test_initialization(mock_w3):
    """Test Web3Utils initialization"""
    utils = Web3Utils("http://localhost:8545")
    assert utils.w3 is not None


def test_get_balance(mock_w3):
    """Test getting account balance"""
    mock_w3.eth.get_balance.return_value = Web3.to_wei(10, 'ether')
    mock_w3.from_wei.return_value = 10.0

    with patch('web3_utils.Web3.to_checksum_address', return_value="0xAddress"):
        utils = Web3Utils()
        balance = utils.get_balance("0xAddress")

        assert balance == 10.0
        mock_w3.eth.get_balance.assert_called_once()


def test_create_account():
    """Test account creation"""
    with patch('web3_utils.Web3'):
        with patch('web3_utils.Account.create') as mock_create:
            mock_account = Mock()
            mock_account.address = "0x123"
            mock_account.key = Mock()
            mock_account.key.hex.return_value = "0xprivatekey"
            mock_create.return_value = mock_account

            utils = Web3Utils()
            account = utils.create_account()

            assert 'address' in account
            assert 'private_key' in account
            assert account['address'] == "0x123"


def test_sign_message():
    """Test message signing"""
    with patch('web3_utils.Web3') as mock_web3:
        mock_w3_instance = Mock()
        mock_w3_instance.is_connected.return_value = True
        mock_w3_instance.keccak.return_value = b'message_hash'
        mock_web3.return_value = mock_w3_instance

        with patch('web3_utils.Account.from_key') as mock_from_key:
            mock_account = Mock()
            mock_signed = Mock()
            mock_signed.signature = Mock()
            mock_signed.signature.hex.return_value = "0xsignature"
            mock_account.signHash.return_value = mock_signed
            mock_from_key.return_value = mock_account

            utils = Web3Utils()
            signature = utils.sign_message("test message", "0xprivatekey")

            assert signature == "0xsignature"


def test_wait_for_transaction(mock_w3):
    """Test waiting for transaction receipt"""
    mock_receipt = {
        'transactionHash': '0xhash',
        'blockNumber': 12345,
        'status': 1
    }
    mock_w3.eth.wait_for_transaction_receipt.return_value = mock_receipt

    utils = Web3Utils()
    receipt = utils.wait_for_transaction("0xhash")

    assert receipt['blockNumber'] == 12345
    assert receipt['status'] == 1


def test_call_contract_function(mock_w3):
    """Test calling read-only contract function"""
    mock_contract = Mock()
    mock_function = Mock()
    mock_function.return_value.call.return_value = "result"
    mock_contract.functions.testFunction = mock_function

    mock_w3.eth.contract.return_value = mock_contract

    with patch('web3_utils.Web3.to_checksum_address', return_value="0xContract"):
        utils = Web3Utils()
        result = utils.call_contract_function(
            "0xContract",
            [],
            "testFunction",
            "arg1"
        )

        assert result == "result"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
