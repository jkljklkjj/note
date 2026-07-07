Transformer 是 2017 年 Google 提出的架构，核心创新是**完全抛弃 RNN，只用注意力机制**。

它由 **Encoder（编码器）** 和 **Decoder（解码器）** 两大部分组成。
```
输入序列
    ↓
[Embedding + 位置编码]
    ↓
┌─────────────────────────────────┐
│         Encoder Stack           │
│  ┌───────────────────────────┐  │
│  │  Multi-Head Self-Attention │  │
│  │       + Add & Norm         │  │
│  │  Feed-Forward Network       │  │
│  │       + Add & Norm         │  │
│  └───────────────────────────┘  │
│              × N                 │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│         Decoder Stack           │
│  ┌───────────────────────────┐  │
│  │  Masked Multi-Head Self-Attention │
│  │       + Add & Norm         │  │
│  │  Cross-Attention（Encoder输出）│
│  │       + Add & Norm         │  │
│  │  Feed-Forward Network       │  │
│  │       + Add & Norm         │  │
│  └───────────────────────────┘  │
│              × N                 │
└─────────────────────────────────┘
    ↓
输出概率
```

#### Embedding

将每个token转成高维向量，给电脑理解。比如“爱”这个token，在好坏的维度是好的，在情感的色彩中是温暖的。就能通过数字去量化这些不同维度的分数

```python
class InputEmbedding(nn.Module):
    def __init__(self, vocab_size, d_model):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, d_model)
        self.d_model = d_model
    
    def forward(self, x):
        # 将 token ID 转换为 d_model 维向量
        # 并乘以 sqrt(d_model) 缩放
        return self.embedding(x) * math.sqrt(self.d_model)
```

这个转换操作怎么做呢
1. **随机初始化**每个词的向量（比如 300 维，每个维度的值随机）
2. 拿**一句话，遮住一个词**，让模型猜
3. 模型用当前向量**算一个猜测**
4. 对比正确答案，**计算误差**
5. 用**反向传播**，微调这些向量，让下次更准
6. 重复几亿次

#### 位置编码

因为 Transformer 没有循环或卷积，所以需要显式注入位置信息。也就是说不知道“你”出现在“我爱”的后面还是前面，如果没有位置信息，后面练出来的模型可能输出“你我爱”还是“我你爱”还是“我爱你”

不同的位置编码对于位置的理解也不同。最经典的是通过余弦，"你“的嵌入向量和余弦向量相乘，它的信息就包含了对应的位置

```python
class PositionalEncoding(nn.Module):
    def __init__(self, d_model, max_len=5000):
        super().__init__()
        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len).unsqueeze(1)
        
        # 计算不同维度的频率
        div_term = torch.exp(
            torch.arange(0, d_model, 2) * -(math.log(10000.0) / d_model)
        )
        
        # 偶数维度用 sin，奇数维度用 cos
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        
        self.register_buffer('pe', pe.unsqueeze(0))
    
    def forward(self, x):
        return x + self.pe[:, :x.size(1)]
```

#### 自注意力

这是Transformer和核心创新，也很伟大。每个token对应的高维向量经过转换后得出三个标签，QKV。分别代表这个token的问题、标签、内容的含义

Attention本质是“按相关性做加权聚合”：给定 Query（当前需求）、Key（索引线索）、Value（内容），先算 Q-K 相似度，再对 V 做加权求和。它让模型在每一步都能动态关注最相关上下文，而不是把信息压缩成固定向量

```python
Q = 嵌入 × W_Q
K = 嵌入 × W_K
V = 嵌入 × W_V
```

```python
class SelfAttention(nn.Module):
    def __init__(self, d_model, d_k):
        super().__init__()
        self.d_k = d_k
        # Q、K、V 的投影矩阵
        self.W_q = nn.Linear(d_model, d_k)
        self.W_k = nn.Linear(d_model, d_k)
        self.W_v = nn.Linear(d_model, d_k)
    
    def forward(self, x, mask=None):
        # x: (batch, seq_len, d_model)
        Q = self.W_q(x)  # (batch, seq_len, d_k)
        K = self.W_k(x)  # (batch, seq_len, d_k)
        V = self.W_v(x)  # (batch, seq_len, d_k)
        
        # 计算注意力分数
        scores = torch.matmul(Q, K.transpose(-2, -1))  # (batch, seq_len, seq_len)
        scores = scores / math.sqrt(self.d_k)  # 缩放
        
        if mask is not None:
            scores = scores.masked_fill(mask == 0, -1e9)
        
        attention_weights = F.softmax(scores, dim=-1)
        output = torch.matmul(attention_weights, V)  # (batch, seq_len, d_k)
        
        return output
```

#### 多头注意力

解决了token列表和token的关系问题。如果没有多头注意力，比如“你”出现的概率计算只会根据前一个token”爱“决定，但是引入后就会跟”我爱“这个token列表决定。这样的话模型就有了上下文的能力

```python
class MultiHeadAttention(nn.Module):
    def __init__(self, d_model, num_heads):
        super().__init__()
        assert d_model % num_heads == 0
        
        self.num_heads = num_heads
        self.d_k = d_model // num_heads
        
        # 一次性投影，再拆分
        self.W_q = nn.Linear(d_model, d_model)
        self.W_k = nn.Linear(d_model, d_model)
        self.W_v = nn.Linear(d_model, d_model)
        self.W_o = nn.Linear(d_model, d_model)
    
    def split_heads(self, x):
        batch, seq_len, _ = x.shape
        x = x.view(batch, seq_len, self.num_heads, self.d_k)
        return x.transpose(1, 2)  # (batch, num_heads, seq_len, d_k)
    
    def combine_heads(self, x):
        batch, _, seq_len, _ = x.shape
        x = x.transpose(1, 2).contiguous()
        return x.view(batch, seq_len, -1)
    
    def forward(self, Q, K, V, mask=None):
        # 投影
        Q = self.split_heads(self.W_q(Q))
        K = self.split_heads(self.W_k(K))
        V = self.split_heads(self.W_v(V))
        
        # 计算注意力（可并行处理所有头）
        scores = torch.matmul(Q, K.transpose(-2, -1)) / math.sqrt(self.d_k)
        if mask is not None:
            scores = scores.masked_fill(mask == 0, -1e9)
        
        attention = F.softmax(scores, dim=-1)
        output = torch.matmul(attention, V)
        
        # 合并头
        output = self.combine_heads(output)
        output = self.W_o(output)
        
        return output
```

#### 前馈网络

FFN做的就是，增强现在的嵌入向量，让后面训练的效果更好

```python
class PositionwiseFeedForward(nn.Module):
    def __init__(self, d_model, d_ff):
        super().__init__()
        self.linear1 = nn.Linear(d_model, d_ff)
        self.linear2 = nn.Linear(d_ff, d_model)
    
    def forward(self, x):
        # 论文中用 ReLU，现在常用 GELU
        return self.linear2(F.gelu(self.linear1(x)))
```

#### 残差连接 + 层归一化

**残差连接**：解决深层网络梯度消失问题  
**层归一化**：稳定训练，加速收敛

```python
class AddNorm(nn.Module):
    def __init__(self, d_model, dropout=0.1):
        super().__init__()
        self.norm = nn.LayerNorm(d_model)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x, sublayer_output):
        # 残差连接 + 层归一化
        return self.norm(x + self.dropout(sublayer_output))
```