**动态SQL就是根据不同的条件生成不同的SQL语句**

动态 SQL 元素和 JSTL或任何基于类 XML 语言的文本处理器相似。在 MyBatis 之前的版本中，需要花时间了解大量的元素。借助功能强大的基于 OGNL 的表达式，MyBatis 3 替换了之前的大部分元素，大大精简了元素种类，现在要学习的元素种类比原来的一半还要少。

 - if
 - choose (when, otherwise)
 - trim (where, set)
 - foreach

创建数据库
```sql
CREATE TABLE `blog`(
`id` VARCHAR(50) NOT NULL COMMENT '博客id',
`title` VARCHAR(100) NOT NULL COMMENT '博客标题',
`author` VARCHAR(30) NOT NULL COMMENT '博客作者',
`create_time` DATETIME NOT NULL COMMENT '创建时间',
`views` INT(30) NOT NULL COMMENT '浏览量'
)ENGINE=INNODB DEFAULT CHARSET=utf8;
```

实体
```java
@Alias("blog")
@Data
public class Blog {
    private int id;
    private String title;
    private String author;
    private Date createTime;
    private int views;
}
```

编写mapper和配置
```java
public interface BlogMapper {
    //插入数据
    int addBlog(Blog blog);
}
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.hwt.dao.BlogMapper">

    <insert id="addBlog">
        insert into blog (id, title, author, create_time, views)
        VALUE (#{id},#{title},#{author},#{createTime},#{views});
    </insert>
</mapper>
```

插入实验数据
```java
public class ITest {
    @Test
    public void addBlog(){
        SqlSession sqlSession = MybatisUntils.getSqlSession();
        BlogMapper mapper = sqlSession.getMapper(BlogMapper.class);
        Blog blog = new Blog();
        blog.setId(IdUtils.getId());
        blog.setTitle("保证SQL的可读性，尽量保证通俗易懂");
        blog.setAuthor("高启强");
        blog.setCreateTime(new Date());
        blog.setViews(6666);
        mapper.addBlog(blog);

        blog.setId(IdUtils.getId());
        blog.setTitle("注意一对多和多对一中，属性名和字段的问题");
        blog.setAuthor("高启盛");
        mapper.addBlog(blog);

        blog.setId(IdUtils.getId());
        blog.setTitle("如果问题不好排查错误，可以使用日志，建议使用log4j");
        blog.setAuthor("麻子");
        mapper.addBlog(blog);

        sqlSession.close();
    }
}
```

#### if

接口
```java
//查询博客
List<Blog> queryBlogIf(Map map);
```

xml
如果test中的语句成立
中间的语句就会被加到原语句后面
```xml
<select id="queryBlogIf" parameterType="map" resultType="blog">
    select * from blog where 1=1
    <if test="title != null">
        and title = #{title}
    </if>
    <if test="author != null">
        and author = #{author}
    </if>
</select>
```

#### choose、when、otherwise

**choose**：不想使用所有的条件，而只是想从多个条件中选择一个使用。针对这种情况，MyBatis 提供了 choose 元素，它有点像 Java 中的 switch 语句。
```xml
<select id="queryBlogChoose" resultType="Blog" parameterType="map">
    select * from blog 
    <where>
        <choose>
            <when test="title != null">
                title = #{title}
            </when>
            <otherwise>
                and views = #{views}
            </otherwise>
        </choose>
    </where>    
</select>
```

#### trim、where、set

**where**：where 元素只会在子元素返回任何内容的情况下才插入 “WHERE” 子句。而且，若子句的开头为 “AND” 或 “OR”，_where_ 元素也会将它们去除
其中返回值为插入原语句后的语句
```xml
<select id="queryBlogIf" parameterType="map" resultType="blog">
    select * from blog
    <where>
        <if test="title != null">
            title = #{title}
        </if>
        <if test="author != null">
            and author = #{author}
        </if>
    </where>
</select>
```

**set**：set 元素会动态地在行首插入 SET 关键字，并会删掉额外的逗号（这些逗号是在使用条件语句给列赋值时引入的）或者，可以通过使用_trim_元素来达到同样的效果
```xml
<update id="updateBlog" parameterType="map">
    update blog
    <set>
        <if test="title != null">
            title = #{title},
        </if>
        <if test="author != null">
            author = #{author}
        </if>
    </set>
    where id = #{id}
</update>
```

**trim**：prefix/suffix属性：如果trim后内容不为空，则增加某某字符串（作前缀/后缀）；  
如果trim后内容不为空，则删掉（前缀/后缀的）某某字符串
```xml
<trim prefix="SET" suffixOverrides=",">
  ...
</trim>
```

#### SQL片段

就是将sql中一些功能片段提取出来，方便使用

使用sql标签抽取公共部分
```xml
<sql id="if-title-author">
    <if test="title != null">
        title = #{title}
    </if>
    <if test="author != null">
        and author = #{author}
    </if>
</sql>
```

在需要使用的地方使用Include标签引用
```xml
<select id="queryBlogIf" parameterType="map" resultType="blog">
    select * from blog
    <where>
        <include refid="if-title-author"></include>
    </where>
</select>
```