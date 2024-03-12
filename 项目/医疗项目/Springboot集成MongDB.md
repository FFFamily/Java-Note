# Springboot集成MongDB

## 1，导入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

## 2，配置

```properties
spring.data.mongodb.uri=mongodb://localhost:27017/dbname
```

## 3，实体类

## 4，添加Repository

```java
// Hospital 是实体类
@Repository
public interface HospitalRepository extends MongoRepository<Hospital,String> {
    Hospital getHospitalByHoscode(String hoscode);
}
```

## 5，service接口

### 问题

hospitalRepository中的接口方法，并没有发现谁去实现了，那么是怎么执行的呢

```java
public interface HospitalService {
    /**
     * 上传医院信息
     * @param paramMap
     */
    void save(Map<String, Object> paramMap);
}

@Service
public class HospitalServiceImpl implements HospitalService {
    @Autowired
    private HospitalRepository hospitalRepository;
    @Override
    public void save(Map<String, Object> paramMap) {
       Hospital hospital = JSONObject.parseObject(JSONObject.toJSONString(paramMap),Hospital.class);
       //判断是否存在
    	Hospital targetHospital = hospitalRepository.getHospitalByHoscode(hospital.getHoscode());
    	if(null != targetHospital) {
            // 对实体进行赋值
            hospital.setStatus(targetHospital.getStatus());
            // 保存功能
            hospitalRepository.save(hospital);
       	} else {
    		//0：未上线 1：已上线
    		hospital.setStatus(0);
          	// 赋值
    		hospitalRepository.save(hospital);
       }
    }

}
```

查询

> 代码实现中查询较为不一样，其他的都是直接调用方法

```java
@Override
public Page<Hospital> selectPage(Integer page, Integer limit, HospitalQueryVo hospitalQueryVo) {
    Sort sort = Sort.by(Sort.Direction.DESC, "createTime");
    //0为第一页
    Pageable pageable = PageRequest.of(page-1, limit, sort);

    Hospital hospital = new Hospital();
    BeanUtils.copyProperties(hospitalQueryVo, hospital);

    //创建匹配器，即如何使用查询条件
    //构建对象
    ExampleMatcher matcher = ExampleMatcher.matching() 
    .withStringMatcher(ExampleMatcher.StringMatcher.CONTAINING) //改变默认字符串匹配方式：模糊查询
    .withIgnoreCase(true); //改变默认大小写忽略方式：忽略大小写

    //创建实例
    Example<Hospital> example = Example.of(hospital, matcher);
    Page<Hospital> pages = hospitalRepository.findAll(example, pageable);

    pages.getContent().stream().forEach(item -> {
    	this.packHospital(item);
    });
	return pages;	
}
/**
* 封装数据
* @param hospital
* @return
*/
private Hospital packHospital(Hospital hospital) {
    String hostypeString = dictFeignClient.getName(DictEnum.HOSTYPE.getDictCode(),hospital.getHostype());
    String provinceString = dictFeignClient.getName(hospital.getProvinceCode());
    String cityString = dictFeignClient.getName(hospital.getCityCode());
    String districtString = dictFeignClient.getName(hospital.getDistrictCode());
    hospital.getParam().put("hostypeString", hostypeString);
    hospital.getParam().put("fullAddress", provinceString + cityString + districtString + hospital.getAddress());
    return hospital;
}

```

