首先创建一个类
```java
package com.example.caching;

public class Book {

  private String isbn;
  private String title;

  public Book(String isbn, String title) {
    this.isbn = isbn;
    this.title = title;
  }

  public String getIsbn() {
    return isbn;
  }

  public void setIsbn(String isbn) {
    this.isbn = isbn;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  @Override
  public String toString() {
    return "Book{" + "isbn='" + isbn + '\'' + ", title='" + title + '\'' + '}';
  }

}
```

创建这个对象的储存库
```java
package com.example.caching;

public interface BookRepository {

  Book getByIsbn(String isbn);

}
```

您可以使用 {SpringData}[Spring Data] 在各种 SQL 或 NoSQL 存储中提供存储库的实现。但是，出于本指南的目的，您将简单地使用模拟一些延迟（网络服务、慢延迟或其他问题）的天真实现
```java
package com.example.caching;

import org.springframework.stereotype.Component;

@Component
public class SimpleBookRepository implements BookRepository {

  @Override
  public Book getByIsbn(String isbn) {
    simulateSlowService();
    return new Book(isbn, "Some book");
  }

  // Don't do this at home
  private void simulateSlowService() {
    try {
	// 模拟延迟
      long time = 3000L;
      Thread.sleep(time);
    } catch (InterruptedException e) {
      throw new IllegalStateException(e);
    }
  }
}
```

连接存储库来读取数据
```java
package com.example.caching;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class CachingApplication {

  public static void main(String[] args) {
    SpringApplication.run(CachingApplication.class, args);
  }

}
```

多次调用
```java
package com.example.caching;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class AppRunner implements CommandLineRunner {

  private static final Logger logger = LoggerFactory.getLogger(AppRunner.class);

  private final BookRepository bookRepository;

  public AppRunner(BookRepository bookRepository) {
    this.bookRepository = bookRepository;
  }

  @Override
  public void run(String... args) throws Exception {
    logger.info(".... Fetching books");
    logger.info("isbn-1234 -->" + bookRepository.getByIsbn("isbn-1234"));
    logger.info("isbn-4567 -->" + bookRepository.getByIsbn("isbn-4567"));
    logger.info("isbn-1234 -->" + bookRepository.getByIsbn("isbn-1234"));
    logger.info("isbn-4567 -->" + bookRepository.getByIsbn("isbn-4567"));
    logger.info("isbn-1234 -->" + bookRepository.getByIsbn("isbn-1234"));
    logger.info("isbn-1234 -->" + bookRepository.getByIsbn("isbn-1234"));
  }

}
```
运行后发现，特别慢
接下来我们启用缓存来改善这种情况

启动缓存将书籍缓存在缓存中
```java
package com.example.caching;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Component;

@Component
public class SimpleBookRepository implements BookRepository {

	// 设置缓存
  @Override
  @Cacheable("books")
  public Book getByIsbn(String isbn) {
    simulateSlowService();
    return new Book(isbn, "Some book");
  }

  // Don't do this at home
  private void simulateSlowService() {
    try {
      long time = 3000L;
      Thread.sleep(time);
    } catch (InterruptedException e) {
      throw new IllegalStateException(e);
    }
  }
}
```

在启动类中允许缓存
```java
package com.example.caching;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class CachingApplication {

  public static void main(String[] args) {
    SpringApplication.run(CachingApplication.class, args);
  }

}
```
第一次检索书籍仍需要 3 秒。但是，同一本书的第二次和后续时间要快得多，这表明缓存正在执行其工作