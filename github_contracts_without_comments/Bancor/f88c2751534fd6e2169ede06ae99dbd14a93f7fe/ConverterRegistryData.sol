
pragma solidity 0.6.12;
import ;
import ;


contract converterregistrydata is iconverterregistrydata, contractregistryclient {
    struct item {
        bool valid;
        uint256 index;
    }

    struct items {
        address[] array;
        mapping(address => item) table;
    }

    struct list {
        uint256 index;
        items items;
    }

    struct lists {
        address[] array;
        mapping(address => list) table;
    }

    items private smarttokens;
    items private liquiditypools;
    lists private convertibletokens;

    
    constructor(icontractregistry _registry) contractregistryclient(_registry) public {
    }

    
    function addsmarttoken(iconverteranchor _anchor) external override only(converter_registry) {
        additem(smarttokens, address(_anchor));
    }

    
    function removesmarttoken(iconverteranchor _anchor) external override only(converter_registry) {
        removeitem(smarttokens, address(_anchor));
    }

    
    function addliquiditypool(iconverteranchor _liquiditypoolanchor) external override only(converter_registry) {
        additem(liquiditypools, address(_liquiditypoolanchor));
    }

    
    function removeliquiditypool(iconverteranchor _liquiditypoolanchor) external override only(converter_registry) {
        removeitem(liquiditypools, address(_liquiditypoolanchor));
    }

    
    function addconvertibletoken(ierc20token _convertibletoken, iconverteranchor _anchor) external override only(converter_registry) {
        list storage list = convertibletokens.table[address(_convertibletoken)];
        if (list.items.array.length == 0) {
            list.index = convertibletokens.array.length;
            convertibletokens.array.push(address(_convertibletoken));
        }
        additem(list.items, address(_anchor));
    }

    
    function removeconvertibletoken(ierc20token _convertibletoken, iconverteranchor _anchor) external override only(converter_registry) {
        list storage list = convertibletokens.table[address(_convertibletoken)];
        removeitem(list.items, address(_anchor));
        if (list.items.array.length == 0) {
            address lastconvertibletoken = convertibletokens.array[convertibletokens.array.length  1];
            convertibletokens.table[lastconvertibletoken].index = list.index;
            convertibletokens.array[list.index] = lastconvertibletoken;
            convertibletokens.array.pop();
            delete convertibletokens.table[address(_convertibletoken)];
        }
    }

    
    function getsmarttokencount() external override view returns (uint256) {
        return smarttokens.array.length;
    }

    
    function getsmarttokens() external override view returns (address[] memory) {
        return smarttokens.array;
    }

    
    function getsmarttoken(uint256 _index) external override view returns (iconverteranchor) {
        return iconverteranchor(smarttokens.array[_index]);
    }

    
    function issmarttoken(address _value) external override view returns (bool) {
        return smarttokens.table[_value].valid;
    }

    
    function getliquiditypoolcount() external override view returns (uint256) {
        return liquiditypools.array.length;
    }

    
    function getliquiditypools() external override view returns (address[] memory) {
        return liquiditypools.array;
    }

    
    function getliquiditypool(uint256 _index) external override view returns (iconverteranchor) {
        return iconverteranchor(liquiditypools.array[_index]);
    }

    
    function isliquiditypool(address _value) external override view returns (bool) {
        return liquiditypools.table[_value].valid;
    }

    
    function getconvertibletokencount() external override view returns (uint256) {
        return convertibletokens.array.length;
    }

    
    function getconvertibletokens() external override view returns (address[] memory) {
        return convertibletokens.array;
    }

    
    function getconvertibletoken(uint256 _index) external override view returns (ierc20token) {
        return ierc20token(convertibletokens.array[_index]);
    }

    
    function isconvertibletoken(address _value) external override view returns (bool) {
        return convertibletokens.table[_value].items.array.length > 0;
    }

    
    function getconvertibletokensmarttokencount(ierc20token _convertibletoken) external override view returns (uint256) {
        return convertibletokens.table[address(_convertibletoken)].items.array.length;
    }

    
    function getconvertibletokensmarttokens(ierc20token _convertibletoken) external override view returns (address[] memory) {
        return convertibletokens.table[address(_convertibletoken)].items.array;
    }

    
    function getconvertibletokensmarttoken(ierc20token _convertibletoken, uint256 _index) external override view returns (iconverteranchor) {
        return iconverteranchor(convertibletokens.table[address(_convertibletoken)].items.array[_index]);
    }

    
    function isconvertibletokensmarttoken(ierc20token _convertibletoken, address _value) external override view returns (bool) {
        return convertibletokens.table[address(_convertibletoken)].items.table[_value].valid;
    }

    
    function additem(items storage _items, address _value) internal validaddress(_value) {
        item storage item = _items.table[_value];
        require(!item.valid, );

        item.index = _items.array.length;
        _items.array.push(_value);
        item.valid = true;
    }

    
    function removeitem(items storage _items, address _value) internal validaddress(_value) {
        item storage item = _items.table[_value];
        require(item.valid, );

        address lastvalue = _items.array[_items.array.length  1];
        _items.table[lastvalue].index = item.index;
        _items.array[item.index] = lastvalue;
        _items.array.pop();
        delete _items.table[_value];
    }
}
