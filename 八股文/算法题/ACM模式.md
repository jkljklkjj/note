统一模板，后面默认在模板里面进行编写，或者省略模板
```java
import java.util.*;

public class Main{
	public static void main(String[] args){
		Scanner sc = new Scanner(System.in);
		
	}
}
```

首先学会IO流，包括
- 字符串
- 数组
- 二维数组
- 链表
- 树

获取对应的数据后，再传入solve()函数进行解答，IO和解答要分开才更容易看清，也符合力扣模式

字符串
```java
String s = sc.next();
```

数组
```java
String t = sc.nextLine();
String[] ts = t.split(" ");
int n = ts.length;
int[] nums = new int[n];
for(int i = 0;i<n;i++){
	nums[i] = Integer.valueOf(ts[i]);
}
```

二维数组
```java
// 注意，这两个变量要自己补充，不能完全复制粘贴样例的
// 不过面试官一般不会管，否则脱离这两个变量IO流会很复杂，集中于代码逻辑即可
int n = sc.nextInt();
int m = sc.nextInt();
int[][] nums = new int[n][m];
for(int i = 0;i<n*m;i++){
	int row = i/n;
	int col = i%m;
	nums[row][col] = sc.nextInt();
}
```

链表，注意要学习哪里应该使用静态
```java
static class ListNode{
	int val;
	ListNode next;
	public ListNode(int val){
		this.val = val;
	}
}

ListNode dummyHead = new ListNode(0);
ListNode cur = dummyHead;
String t = sc.nextLine();
String[] ts = t.split(" ");
for(String s:ts){
	int val = Integer.valueOf(s);
	ListNode node = new ListNode(val);
	cur.next = node;
	cur = cur.next;
}
// 最后dummyHead.next为链表头结点
```

树，因为输入一般为树的先序遍历结果，所以用先序遍历建立
```java
static int index = 0;
static class TreeNode{
	int val;
	TreeNode left;
	TreeNode right;
	public TreeNode(int val){
		this.val = val;
	}

	static TreeNode build(int[] nums){
		if(index>=nums.length || nums[index]==-1){
			index++;
			return null;
		}
		TreeNode node = new TreeNode(nums[index++]);
		node.left = build(nums);
		node.right = build(nums);
		return node;
	}
}

// nums可以看数组是如何扫描的
TreeNode root = TreeNode.build(nums);
```

同时树也可以搞一个包装器，包装一下数组就可以了
```java
static class TreeNode{
	int i;
	
	public TreeNode(int i){
		this.i = i;
	}

	int getVal(){
		return nums[i];
	}
	
	TreeNode getLeft(){
		int index = 2*i;
		if(index>=nums.length) return null;
		if(nums[index]==-1) return null;
		return new TreeNode(index);
	}
	
	TreeNode getRight(){
		int index = 2*i+1;
		if(index>=nums.length) return null;
		if(nums[index]==-1) return null;
		return new TreeNode(index);
	}
}
```

#### 静态
- 定义类的时候要用静态，才能在同一文件给Main类使用
- 定义全局变量的时候要用静态，才能给main方法或者静态方法使用
- 定义方法的时候要静态，才能给作为静态函数的main方法调用

#### 笔试fastReader
如果是面试的时候的算法还好，数据规模从来没超过10，凭感觉判断复杂度 。但是如果遇到笔试题的算法，那是真正的复杂度，通过数据规模去判断你的复杂度对不对。但是如果你复杂度过了，在IO规模大的情况下单靠一个IO时间就能让你超时
```java
Scanner sc = new Scanner(System.in);
while(q--!=0){
	int a = sc.nextInt(), b = sc.nextInt();
}
```

我们要用BufferReader的方式去读取，注意它只有读取一行字符串的功能
```java
BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
String s = br.readLine();
int n = Integer.valueOf(br.readLine());
```

同时可以使用StreamTokenizer去达到类似nextInt()的效果
```java
BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
StreamTokenizer st = new StreamTokenizer(br);
st.nextToken();String s = st.sval;
st.nextToken();int n = (int)st.nval;
```

注意st.nval实际上是double类型，double的表示范围不够long，所以无法读取long类型的数，只能先读取成字符串再转
```java
st.nextToken();long n = (long)st.nval; // 这个错爆了
st.nextToken();long n = Long.valueOf(st.sval);
```

输出时，最好把所有的结果拼接后再输出
```java
// 下面是普通的输出
System.out.println(ans);

// 下面是fastPrinter
StringBuilder out = new StringBuilder();
out.append(ans);
out.append('\n'); // 用char更快
```