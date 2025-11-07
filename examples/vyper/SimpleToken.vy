# @version ^0.3.9
"""
@title Simple ERC-20 Token in Vyper
@notice A minimal ERC-20 implementation showcasing Vyper syntax
@dev Uses Vyper's built-in safety features
"""

from vyper.interfaces import ERC20

implements: ERC20

# Events
event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    amount: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    amount: uint256

# State Variables
name: public(String[64])
symbol: public(String[32])
decimals: public(uint8)
totalSupply: public(uint256)
balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])

@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint8, _total_supply: uint256):
    """
    @notice Initialize the token
    @param _name Token name
    @param _symbol Token symbol
    @param _decimals Number of decimals
    @param _total_supply Initial supply (will be minted to deployer)
    """
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.totalSupply = _total_supply
    self.balanceOf[msg.sender] = _total_supply

    log Transfer(empty(address), msg.sender, _total_supply)

@external
def transfer(_to: address, _value: uint256) -> bool:
    """
    @notice Transfer tokens to another address
    @param _to The recipient address
    @param _value The amount to transfer
    @return Success boolean
    """
    assert _to != empty(address), "Invalid recipient"
    assert self.balanceOf[msg.sender] >= _value, "Insufficient balance"

    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value

    log Transfer(msg.sender, _to, _value)
    return True

@external
def approve(_spender: address, _value: uint256) -> bool:
    """
    @notice Approve an address to spend tokens
    @param _spender The address authorized to spend
    @param _value The maximum amount they can spend
    @return Success boolean
    """
    assert _spender != empty(address), "Invalid spender"

    self.allowance[msg.sender][_spender] = _value

    log Approval(msg.sender, _spender, _value)
    return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    """
    @notice Transfer tokens on behalf of another address
    @param _from The address to transfer from
    @param _to The recipient address
    @param _value The amount to transfer
    @return Success boolean
    """
    assert _to != empty(address), "Invalid recipient"
    assert self.balanceOf[_from] >= _value, "Insufficient balance"
    assert self.allowance[_from][msg.sender] >= _value, "Insufficient allowance"

    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    self.allowance[_from][msg.sender] -= _value

    log Transfer(_from, _to, _value)
    return True
