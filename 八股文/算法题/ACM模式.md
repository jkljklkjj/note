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

#### 静态
- 定义类的时候要用静态，才能在同一文件给Main类使用
- 定义全局变量的时候要用静态，才能给main方法使用
- 