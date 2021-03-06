// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {

  address public owner;

  uint public skuCount;

  mapping (uint => Item) items;

  enum State { ForSale, Sold, Shipped, Received }

  struct Item {
    string name;
    uint sku;
    uint price;
    State state;
    address payable seller;
    address payable buyer;
  }
  
  /* 
   * Events
   */

  event LogForSale(uint sku);
  event LogSold(uint sku);
  event LogShipped(uint sku);
  event LogReceived(uint sku);
  

  /* 
   * Modifiers
   */

  modifier isOwner() {
    require (msg.sender == owner);
    _;
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    // uint _price = items[_sku].price;
    // uint amountToRefund = msg.value - _price;
    // items[_sku].buyer.transfer(amountToRefund);
  }

  modifier forSale(uint _sku) {
    Item memory item = items[_sku];
    require(item.state == State.ForSale && item.seller != address(0));
    _;
  }

  modifier sold(uint _sku) {
      require(items[_sku].state == State.Sold);
    _;
  }

  modifier shipped(uint _sku) {
      require(items[_sku].state == State.Shipped);
    _;
  }
  
  // modifier received(uint _sku) 

  constructor() public {
    owner = msg.sender;
  }

  function addItem(string memory _name, uint _price) public returns (bool) {
    items[skuCount] = Item({
     name: _name, 
     sku: skuCount, 
     price: _price, 
     state: State.ForSale, 
     seller: msg.sender, 
     buyer: address(0)
    });
    
    skuCount = skuCount + 1;
    emit LogForSale(skuCount);
    return true;
  }

  function buyItem(uint sku) payable public 
    paidEnough(msg.value) 
    forSale(sku) 
  {
      Item storage item = items[sku];
    
      item.seller.transfer(item.price);
      item.buyer = msg.sender;
      item.state = State.Sold;

      emit LogSold(sku);
  }

  function shipItem(uint sku) public {
    Item storage item = items[sku];
    
    require(msg.sender == item.seller);
    
    item.state = State.Shipped;
    
    emit LogShipped(sku);
  }

  function receiveItem(uint sku) public 
    shipped(sku)
  {
    Item storage item = items[sku];
    
    require(msg.sender == item.buyer);
    
    item.state = State.Received;
    
    emit LogReceived(sku);
  }

  // Uncomment the following code block. it is needed to run tests
  function fetchItem(uint _sku) public view 
    returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) 
  {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
}
