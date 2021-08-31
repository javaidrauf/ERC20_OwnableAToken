// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20_OwnableAToken is IERC20{
    //mapping to hold balances against EOA accounts
    mapping (address => uint256) private _balances;

    //mapping to hold approved allowance of token to certain address
    //       Owner               Spender    allowance
    mapping (address => mapping (address => uint256)) private _allowances;
 

    //the amount of tokens in existence
    uint256 private _totalSupply;

    //owner
    address public owner;
    
    string public name;
    string public symbol;
    uint256 public decimals;
    
    // events
    event ownerChange(bool success,address newOwnerowner,uint256 amount);
  
    
    // modifier for owner transctions only
    modifier ownerOnly(){
        require(msg.sender == owner, "O-A-Token: Only Token owner allowed");
        _;
    }

    constructor () {
        name = "ERC20_OwnableAToken";
        symbol = "O-A-Token";
        decimals = 18;  //1  - 1000 PKR 1 = 100 Paisa 2 decimal
        owner = msg.sender;
        
        //1 million tokens to be generated
        _totalSupply = 1000000 * 10**decimals; //exponenctial farmola
        //transfer total supply to owner
        _balances[owner] = _totalSupply;
        
        //fire an event on transfer of tokens
        emit Transfer(address(this),owner,_totalSupply);
     }
   
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        address sender = msg.sender;
        require(sender != address(0), "O-A-Token: Address must be valid");
        require(recipient != address(0), "O-A-Token: Address must be valid");
        require(_balances[sender] > amount,"O-A-Token: transfer amount exceeds balance");

        //decrease the balance of token sender account
        _balances[sender] = _balances[sender] - amount;
        
        //increase the balance of token recipient account
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return _allowances[tokenOwner][spender]; //return allowed amount
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address tokenOwner = msg.sender;
        require(tokenOwner != address(0), "O-A-Token: Address must be valid");
        require(spender != address(0), "O-A-Token: Address must be valid");
        
        _allowances[tokenOwner][spender] = amount;
        
        emit Approval(tokenOwner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address tokenOwner, address recipient, uint256 amount) public virtual override returns (bool) {
        address spender = msg.sender;
        uint256 _allowance = _allowances[tokenOwner][spender]; //how much allowed
        require(_allowance > amount, "O-A-Token: transfer amount exceeds allowance");
        
        //deducting allowance
        _allowance = _allowance - amount;
        
        //--- start transfer execution -- 
        
        //owner decrease balance
        _balances[tokenOwner] =_balances[tokenOwner] - amount; 
        
        //transfer token to recipient;
        _balances[recipient] = _balances[recipient] + amount;
        
        emit Transfer(tokenOwner, recipient, amount);
        //-- end transfer execution--
        
        //decrease the approval amount;
        _allowances[tokenOwner][spender] = _allowance;
        
        emit Approval(tokenOwner, spender, amount);
        
        return true;
    }
    
     /**
     * This function will allow owner to change ownership to another valid address
     * 
     * Requirements:
     * - the caller must be Owner of Contract
     * - thw new owner must be valid
     * - amount must be valid
     */
     function changeOwner(address newOwner, uint256 amount) public ownerOnly returns(bool){
         require(newOwner != address(0),"O-A-Token: Address must be valid");
         require(amount > 0, "Amount should be greater than zero");
         require(newOwner != owner, "Provided addres is already an old owner");
         
         transfer(payable(newOwner),amount);
         
         owner = newOwner;
         
         emit ownerChange(true,newOwner,_balances[newOwner]);
         
         return true;
     }

}