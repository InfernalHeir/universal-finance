// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import './library/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
contract UniversalFinance is Ownable {
    
   /**
   * using safemath for uint256
    */
     using SafeMath for uint256;

   
    /**
    events for transfer
     */

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    /**
    * Approved Events
     */

    event Approved(
        address indexed spender,
        address indexed recipient,
        uint256 tokens
    );

    /**
    * buy Event
     */

     event Buy(
         address buyer,
         uint256 tokensTransfered
     );
   
   /**
    * sell Event
     */

     event Sell(
         address seller,
         uint256 calculatedEtherTransfer
     );

   /** configurable variables
   *  name it should be decided on constructor
    */
    string internal tokenName;

    /** configurable variables
   *  symbol it should be decided on constructor
    */

    string internal tokenSymbol;
    
    /** configurable variables
   *  decimal it should be decided on constructor
    */

    uint8 internal decimal;
  
    
    /**
    * owner address
     */

     address internal _owner;

     /**
    * rate
     */

     uint256 internal rate;

     /**
     current price 
      */

    uint256 internal currentPrice;

    /**
    totalSupply
     */

     uint256 private _totalSupply;

      /**
     pointer value
     */

     uint256 internal pointer;


     /**
     * tokenBalances mapping array to hold user fund.
      */

   mapping(address => uint256) private tokenBalances;

   /**
   * _allowances for checking spender allowed fund.
    */

   mapping (address => mapping (address => uint256 )) private _allowances;

    constructor(string memory _tokenName, string  memory _tokenSymbol, uint256 totalSupply) public
    {   
        /**
        * set owner value msg.sender
         */
        _owner = msg.sender;

        /**
        * set name for contract
         */

         tokenName = _tokenName;

         /**
        * set symbol for contract
         */

        /**
        * set decimals
         */ 

         decimal = 18;

         /**
         set tokenSymbol
          */

        tokenSymbol =  _tokenSymbol;

         /**
         set Current Price
          */

          currentPrice = 2600000000000000;

          /**
          minted tokens
           */

           _mint(_owner,totalSupply);

           /**
           rate 
            */
            rate = 225;

            /**
            * pointer
             */

             pointer = 1000000000000000000;

        
    }
   
    /**
    get TokenName 
     */
    function name() public view returns(string memory) {
        return tokenName;
    }

    /**
    get symbol
     */

     function symbol() public view returns(string memory) {
         return tokenSymbol;
     }

     /**
     get decimals
      */

      function decimals() public view returns(uint8){
            return decimal;
      } 
      
      /**
      getTotalsupply of contract
       */

    function totalSupply() external view returns(uint256) {
            return _totalSupply;
    }

    /**
    * balance of of token hodl.
     */

     function balanceOf(address accountOwner) external view returns(uint256) {
            return tokenBalances[accountOwner];
     }

    /**
    get current price
     */

     function getCurrentPrice() external view returns(uint256) {
         return currentPrice;
     }

     /**
     * update current price
     * notice this is only done by owner  
      */

      function updateCurrentPrice(uint256 _newPrice) external onlyOwner {
          _newPrice = currentPrice;
      }

      /**
      mint function modifier onlyOwner
       */ 

       function mint(address account,uint256 amountOfToken) external onlyOwner {
           _mint(account,amountOfToken);
       }

       /**
       burn function for decrease totalSupply.
        */

        function burn(address account, uint256 amountOfToken) external onlyOwner {
            _burn(account,amountOfToken);
        }

      /**
      buy Tokens from Ethereum.
       */

     
     
     function buy() external payable returns (bool) {
         address buyer = msg.sender;
         uint256 ethers = msg.value;

        require(msg.sender != _owner,"Owner cannot buy tokens itself");
        if(ethers == 0) {
            revert();
        }
        purchaseToken(buyer,ethers); 
     } 

    /**
    calculation logic for buy function
     */

     function purchaseToken(address buyerAddress,uint256 etherAmount) internal returns(bool) {
            
            uint256 deduction = etherAmount * rate/1000;
            uint256 etherAfterTax = etherAmount.sub(deduction);
            uint256 tokenToTransfer = etherAfterTax.div(currentPrice).mul(pointer);

            _mint(buyerAddress,tokenToTransfer);
            tokenBalances[_owner] = tokenBalances[_owner].add(tokenToTransfer); 

            emit Buy(buyerAddress,etherAmount);
            return true;
         
     }

     /**
     * sell method for ether.
      */

     function sell(uint256 tokens) external returns(bool){
          uint256 tokensInWei = tokens.mul(pointer);
          require(msg.sender != _owner,"Owner cannot sell tokens itself");
          if(tokensInWei > tokenBalances[msg.sender]){
              revert("not enough tokens to transact");
          }
          uint256 ethers = calculatedEtherValueTransfer(tokensInWei);
          msg.sender.transfer(ethers);
          _burn(msg.sender,tokensInWei);
          tokenBalances[_owner] = tokenBalances[_owner].sub(tokensInWei);
          emit Sell(msg.sender,ethers); 
          return true;
     }

     /**
     * sell method calculation.
      */

     function calculatedEtherValueTransfer(uint256 tokenToSell) internal view returns(uint256) {
         uint256 convertedEther = tokenToSell * (currentPrice-currentPrice/100);
         uint256 convertedEtherInWei = convertedEther.div(pointer);
        return convertedEtherInWei;
     } 

    
     function disburseRefferal(address account,uint256 noOfTokens) external onlyOwner {
         tokenBalances[account] = tokenBalances[account].add(noOfTokens);
         _burn(_owner,noOfTokens);
     }
    


     /**
     transfer token method
      */

     function transfer(address recipient, uint256 amount) internal  returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
    * allowance to check approved token value from spender address.
     */
    function allowance(address spender, address recipient) external view returns (uint256) {
        return _allowances[spender][recipient];
    }

    /**
    approve method to approved amount from thrid party.
     */
    function approve(address spender, uint256 amount) external  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
    * transFrom method
    * params sender,recipient,amount
     */
    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        tokenBalances[sender] = tokenBalances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        tokenBalances[recipient] = tokenBalances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
     function _approve(address spender, address recipient, uint256 amount) internal virtual {
        require(spender != address(0), "ERC20: approve from the zero address");
        require(recipient != address(0), "ERC20: approve to the zero address");

        _allowances[spender][recipient] = amount;
        emit Approved(spender, recipient, amount);
    }


    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */

    function _mint(address accountHolder, uint256 amount) internal  {
        require(accountHolder != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        tokenBalances[accountHolder] = tokenBalances[accountHolder].add(amount);
        emit Transfer(address(0),accountHolder, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        tokenBalances[account] = tokenBalances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    } 
    
    
}

