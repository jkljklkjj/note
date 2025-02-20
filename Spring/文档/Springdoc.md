Springdoc是一个生成在线接口文档的框架

引入依赖
```xml
<!-- 2选1：使用 spring-boot-starter-web 的时候，只用下面的 webmvc-ui 的依赖 -->
<dependency>
   <groupId>org.springdoc</groupId>
   <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
   <version>2.2.0</version>
</dependency>

<!-- 2选1：使用 spring-boot-starter-webflux 的时候，则用下面的 webflux-ui 的依赖 -->
<dependency>
   <groupId>org.springdoc</groupId>
   <artifactId>springdoc-openapi-starter-webflux-ui</artifactId>
   <version>2.2.0</version>
</dependency>
```

#### Controller注解
@Tag 用来设置 Controller 的名称和描述，类似于给 Postman 的 Collections 命名；
@ApiResponses 和 @ApiResponse 用来配置响应；
@Operation 用来设置接口名称和描述；
@Parameter 用来设置请求参数的描述、是否必填和示例。

```java
@RestController
// 响应的 MediaType 都是 application/json
@RequestMapping(path = "/process-definition", produces = "application/json")
// Tag 注解, 给整个接口起了个名字 "流程定义", 描述是 "流程定义 API"
@Tag(name = "流程定义", description = "流程定义 API")
// ApiResponses 给每个接口提供一个默认的响应, 状态码是 200, 描述是 "接口请求成功"
@ApiResponses(@ApiResponse(responseCode = "200", description = "接口请求成功"))
public class ProcessDefinitionController {

    // Operation 注解设置了接口名称, 接口描述
    @Operation(summary = "上传 BPMN xml 字符串 并部署", description = "此接口处理的是 xml 字符串")
    @PostMapping("/upload-and-deploy/bpmn-xml-str")
    public JsonResult<?> uploadAndDeployBpmnXmlStr(@RequestBody BpmnXmlReq req) {
        return JsonResult.of(CommonCodeEnum.OK);
    }

    @Operation(summary = "查询单个 bpmn xml 数据")
    @GetMapping("/bpmn-xml")
    public JsonResult<BpmnXmlResp> findBpmnXml(
            // Parameter 注解设置了请求参数的描述, 是否必填 以及示例
            @Parameter(description = "流程部署ID", required = true, example = "1234") String deployId,
            @Parameter(description = "流程资源名称", required = true, example = "xxx.bpmn") String resourceName) {
        return JsonResult.of(CommonCodeEnum.OK, new BpmnXmlResp());
    }
}
```

#### 实体类注解
```java
@Data
// Schema 注解设置这个类的描述
@Schema(description = "bpmn xml 请求参数")
public class BpmnXmlReq {
    // Schema 注解设置每个属性的描述和示例
    @Schema(description = "bpmn文件的内容, 字符串格式", example = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    private String xml;
    @Schema(description = "流程部署名称", example = "请假流程")
    private String deployName;
}


@Schema(description = "json结构的响应")
public class JsonResult<T> {
    @Schema(description = "状态码", example = "200")
    private Integer code;
    @Schema(description = "状态码对应的信息", example = "请求成功")
    private String message;
    @Schema(description = "给前端返回的 json 格式的内容")
    private T content;
    // 省略部分内容
}
```