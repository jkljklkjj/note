在运行之前，需要配置好GOPATH和GOROOT

在`main.go`中编写
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello World!")
}
```

- `package main` 定义包名，如果包名为 `main` ，其应该包含 `func main() {}` 否则不该包含。
    
- `import` 有两种用法：
```go
import "fmt"
```

```go
import (
    "fmt"
    "time"
)
```