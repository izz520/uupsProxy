这是一个UUPS透明代理的简单实现，主要就是通过delegateCall的形式实现。

在Proxy代理中，如果调用的方法名不存在，且Proxy中存在fallback方法，则会将调用的方法走到fallback上，我们利用这个原理，然后再利用delegateCall的形式，将calldatadata传递过去即可

1. 先部署两个实现合约,代码如下，分别部署implementation1和implementation2
    
    ```solidity
    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;
    
    //第一版
    contract implementation1 {
        address public implementation;
        address public admin;
        string public name;
        uint256 public count;
    
        function init(string memory _name,uint256 _count) public {
            name = _name;
            count = _count;
            admin = msg.sender;
        }
    
        function setName(string memory _name) public {
            name  =_name;
        }
    
        function addCount() public {
            count+=1;
        }
    
        function update(address _newAddress) public {
            require(msg.sender == admin,"must admin");
            implementation = _newAddress;
        }
    }
    
    //第二版
    contract implementation2 {
        address public implementation;
        address public admin;
        string public name;
        uint256 public count;
    
        function init(string memory _name,uint256 _count) public {
            name = _name;
            count = _count;
            admin = msg.sender;
        }
    
        function setName(string memory _name) public {
            name  =_name;
        }
    
        function addCount() public {
            count+=1;
        }
    
        function setCount(uint256 _count) public {
            count = _count;
        }
    
        function update(address _newAddress) public {
            require(msg.sender == admin,"must admin");
            implementation = _newAddress;
        }
    }
    ```
    

1. 通过remix部署后，复制implementation的合约地址，然后部署UUPS Proxy代理合约，并将implementation设置为刚才复制的implementation1合约地址，代码如下
    
    ```solidity
    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.20;
    
    contract UUPSProxy {
        address public implementation;
        address public admin;
        string public name;
        uint256 public count;
    
        // 构造函数，初始化admin和逻辑合约地址
        constructor(address _implementation) {
            admin = msg.sender;
            implementation = _implementation;
        }
    
        // fallback函数，将调用委托给逻辑合约
        fallback() external payable {
            (bool success, bytes memory data) = implementation.delegatecall(
                msg.data
            );
        }
    }
    
    ```
    
2. 因为是简易版的UUPS代理合约，所以调用实现合约的方法，需要使用到编译后的方法选择器，选择器的code生成可以参考下方的网站
    
    > ABI Encoding Service
    > 
    > 
    > https://abi.hashex.org/
    > 
3. 调用addCount方法
    
    我们可以看到因为是简易的代理合约，所以在代理合约中，并不能看到能调用的方法
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/5602e174-3b67-49ee-85ea-0889b0ec4d7b/image.png)
    

因此，我们只能在实现合约中找到需要调用的方法和参数，去上面的那个网站进行获取选择器code，我们拿addCount为例

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/251f3b87-af3a-4ace-a49a-fdc83eee5942/image.png)

可以看到， 我们addCount的encode data为6cefce6e，我们直接通过remix在UUPS Proxy中调用

![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/e381d4df-2da7-460d-beb3-e1f79a23d6c2/image.png)

通过calldata的调用，我们再次查询count会发现已经由原来的100变成了101了

1. 合约升级
    
    当我们的实现合约有更新的时候，我们同样的需要用上面的网站去获取calldata
    
    根据合约的update方法和参数去生成calldata
    
    ```solidity
        function update(address _newAddress) public {
            require(msg.sender == admin,"must admin");
            implementation = _newAddress;
        }
    ```
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/53a43216-0618-47bb-9b96-cccd7f094770/image.png)
    
    复制生成的calldata后，我们继续到remix中进行执行，按照刚才调用的方式，同样去执行，会发现，我们代理合约里面存储的implementation地址已经更新成了我们现在第二版的实现合约的地址了
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/6a424ca2-cf02-492a-b803-9ec6ae2362ae/image.png)
    
2. 调用第二版的实现合约，我们在第二版中，新增了一个方法
    
    ```solidity
        function setCount(uint256 _count) public {
            count = _count;
        }
    ```
    
    我们直接通过刚才的网站，生成setCount的calldata
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/e6f73968-7c78-4d6d-b550-6291fc11dde6/image.png)
    
    拿到calldata后，我们重复刚才调用addCount或者升级合约的步骤，去remix进行更新
    
    ![image.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/badc4451-af57-4229-82a1-ed81ea673e9b/e7786ce7-7969-4b10-8a4e-ac2849bb35c7/image.png)
    
    通过上诉，我们可以看到，我们存储的count由原来的101变成了1000，到此简单的代理合约就实现了。