// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    bool isTrue = true;
    bool isFalse = false;

    // unsigned integer
    // unit = unit256
    uint256 num8 = 255555556;

    int256 negative = -1;

    // 最大32 存储字符串
    bytes32 byteStr = "Hello World!";
    // bytes bytes[]

    // string 动态分配的bytes 是一个bytes[] 数组
    string str = "Hello World";

    // address
    address addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    //  public  private
    //  internal external
    function sayHello() external view returns (string memory) {
        return addInfo(str);
    }

    function setHelloWorld(string memory newStr) external {
        str = newStr;
    }

    // computed
    function addInfo(string memory helloWorldStr) public  pure returns (string memory){
        return string.concat(helloWorldStr, " form Frank's contract");
    }


    // storage memory calldata stack codes logs
    // 1. storege  永久性存储
    // 2. memory calldata  暂时性存储 一般用于函数入参
    // 3. calldata 运行时无法被修改 
    // 基础数据类型 unit bytes32 int  不需要加任何关键字


    // struct：结构体
    // array：数组
    // mapping：映射
    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos;

    function setInfo(string memory newStr, uint256 _id) external {
        str = newStr;
        Info memory info = Info(newStr, _id, msg.sender);
        infos.push(info);
    }

    
}

