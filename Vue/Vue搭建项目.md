# Vue搭建项目

## 初始化

1，使用ui界面创建项目,勾选需要的依赖

```
vue ui
```



2，使用Element-UI，在创建好的项目页面下选择`插件`

并且设置为按需导入（荧光部分）

![](./img/1.png)



3，安装`Axios`



![](./img/2.png)



4，数据库文件





> 开始之前先



1，看自己的工作去是否干净

```
git status
```

2，首页根组件

```html
<template>
  <div id="app">
   		<!--加上这个就能路由过来-->
        <router-view></router-view>
  </div>
</template>

<script>
    export default {
      name: 'app'
    }
</script>

<style></style>
```

3，删除无用的路由

```
将components中的helloworld.vue删除，以及路由目录下的index.js中的`helloworld.vue`的导入也删除
```



这样，一个干净的项目结构就出来了



## 页面的基本格式

```html
<template></template>

<script>
export default {
  data(){
      return {
          {元素1},
          {元素2}
      }
  }
  methods: {
      f1(){
          
      }
  }
}
</script>

<style lang='less' scoped></style>
```



## 登录功能 

为登录功能创建分支

```
git checkout -b login
```

查看所有分支

```
git branch
```

在Components目录下创建`Login.vue`

```html
<template>
    <div class="login_container"></div>
</template>

<script></script>

<!--这个scoped表示这个样式只对这个组件有效-->
<style lang="less" scoped></style>
```

添加路由

```
const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: Login }
]
```

如果有使用less的css样式就需要去下载依赖

> 这样，就能使得直接访问登录界面



`Login.vue`的相关代码

(简化)

```html
<el-form ref="LoginFormRef" :model="loginForm" :rules="loginFormRules">
    <!-- 用户名 -->
    <el-form-item prop="username">
        <el-input v-model="loginForm.username"></el-input>  
    </el-form-item> 
    <!-- 密码 -->
    <el-form-item prop="password">
        <el-input type="password" v-model="loginForm.password"></el-input>
    </el-form-item> 
    <!-- 按钮 -->
    <el-form-item class="btns">
        <el-button type="primary" @click="login">登录</el-button>
        <el-button type="info" @click="resetLoginForm">重置</el-button>
    </el-form-item> 
</el-form>
```

1，使用双向绑定获取  `form`  表单中的成员，并封装为一个对象，即   `loginForm` ,同时使用`v-model`绑定对象中的数据

 2，为了方便能操作form表单，需要给表单加一个指向 `ref`  ，这样就能在方法中通过`this.$refs.LoginFormRef`  访问到了，然后对其进行操作，更多的操作在官方文档中查看

3，若要进行表单验证，需要使用 `:rules`  并指定 验证规则，这个规则也是放在  `data ` 数据中，通过

<el-form-item>

的prop属性设置验证规则

<el-form-item label="活动名称" prop="username">

----

(相关方法)

![](./img/3.png)



----

```javascript
export default {
    data() {
      return {
        //数据绑定
        loginForm: {
          username: 'admin',
          password: '123456'
        },
        //表单验证规则
        loginFormRules: {
          username: [
            { required: true, message: '请输入登录名', trigger: 'blur' },
            {
              min: 3,
              max: 10,
              message: '登录名长度在 3 到 10 个字符',
              trigger: 'blur'
            }
          ],
          password: []
        }
      }
    }
```



4，弹窗提示

先在`element.js`中导入组件，并全局挂载，然后就可以通过`this`编写弹窗的代码

```javascript
import {Message} from 'element-ui'

Vue.prototype.$message = Message;
```

5，导入`axios`以发送`ajax`请求

打开`main.js`

```javascript
import axios from 'axios';
/设置请求的根路径：
axios.defaults.baseURL = 'http://127.0.0.1:8888/api/private/v1/';
/挂载axios：
Vue.prototype.$http = axios;
```

表单验证的代码

```javascript
login() {
      //点击登录的时候先调用validate方法验证表单内容是否有误
      this.$refs.LoginFormRef.validate(async valid => {
        console.log(this.loginFormRules)
        //如果valid参数为true则验证通过
        if (!valid) {
          return
        }
        //发送请求进行登录
        /**
         * await 用在哪里
         */
        //data: res =》 我们只拿到返回的结果中的data，并重命名为res
        const { data: res } = await this.$http.post('login', this.loginForm)

        if (res.meta.status !== 200) {
          return this.$message.error('登录失败:' + res.meta.msg)
        }
        this.$message.success('登录成功')
          	
        //保存token, 保存在 sessionStorage , 浏览器存在才会生效，关闭就会失效
        window.sessionStorage.setItem('token', res.data.token)
        // 导航至/home
        this.$router.push('/home')
      })
    }
```



## 登出功能

在`home`页面添加一个点击方法就可以了

```javascript
 methods: {
    logout() {
      window.sessionStorage.clear()
      this.$router.push('/login')
    }
  }
```



## 拦截功能

在`router.js`中配置

```javascript
//挂载路由导航守卫,to表示将要访问的路径，from表示从哪里来，next是下一个要做的操作
router.beforeEach((to,from,next)=>{ 
  if(to.path === '/login')
    return next();
  //获取token
  const tokenStr = window.sessionStorage.getItem('token');
  if(!tokenStr)
    return next('/login');
  next();
})
```





## 用户模块

> 前面的内容忘记了

### 与操作相关

相关按钮

```html
<!-- 分配角色 -->
<el-tooltip class="item" effect="dark" content="分配" placement="top":enterable="false">
	<el-button type="warning" icon="el-icon-setting" size='mini'></el-button>
</el-tooltip>
```

分页面板

> 在`elementui`中的`Pagination分页`,需要导入`Pagination`组件

```javascript
import {Pagination} from 'element-ui'
Vue.use(Pagination)
```

页面代码

```html
<!-- 前面两个是方法，监听每页数据和当前页面的变化而执行方法  -->
<!-- current-page指当前页面 -->
<!-- page-sizes指有几种每页数据的显示 -->
<!-- layout指显示那些内容 -->
<!-- total指当前页面 -->
<el-pagination
	@size-change="handleSizeChange" 
	@current-change="handleCurrentChange" 
	:current-page="queryInfo.pagenum" 
	:page-sizes="[1, 2, 5, 10]" 
	:page-size="queryInfo.pagesize" 
	layout="total, sizes, prev, pager, next, jumper" 
	:total="total">
</el-pagination>
```

然后就只需要添加相关方法

```javascript
handleSizeChange(newSize){
    this.queryInfo.pagesize = newSize
    this.getUserList()
},
handleCurrentChange(newPage){
    this.queryInfo.pagenum = newPage
    this.getUserList()
}
```



### 状态的改变

在`Switch`中的`Events`可以找到

在`el-switch` 标签中增加监听方法，将对象信息传递过去，发出put请求，修改对应id对象的状态

```javascript
async userStateChanged(userinfo) {
      console.log(userinfo)
      const { data: res } = await this.$http.put(
        `users/${userinfo.id}/state/${userinfo.mg_state}`
      )
      if (res.meta.status !== 200) {
        userinfo.mg_state = !userinfo.mg_state
        return this.$message.error('更新用户状态失败')
      }
      this.$message.success('更新用户状态成功')
    },
```



### 搜索功能

`inout标签`中双向绑定`queryInfo.query`这里存放的就是搜索的信息

点击搜索后就会执行`getUserList`方法，其参数就是`queryInfo`，内部封装了模糊查询的方法

```html
<el-input placeholder="请输入" 
	v-model="queryInfo.query" 
    clearable 
    @clear="getUserList">
	<el-button slot="append" icon="el-icon-search" @click="getUserList"></el-button>
</el-input> 
```

--

```javascript
async getUserList() {
      //发送请求获取用户列表数据
      const { data: res } = await this.$http.get('users', {
        params: this.queryInfo
      })
      //如果返回状态为异常状态则报错并返回
      if (res.meta.status !== 200)
        return this.$message.error('获取用户列表失败')
      //如果返回状态正常，将请求的数据保存在data中
      this.userList = res.data.users;
      this.total = res.data.total;
    },
```



### 添加用户

增加消息提示框

先引入

```javascript
import {Dialog} from 'element-ui'
Vue.use(Dialog)
```

在`ElementUi` 中找到`Dialog`

-

```
绑定提示框的显示 （true为显示，false为关闭）:visible.sync="dialogVisible" 
绑定方法，在提示框关闭后执行的方法  @close="addDialogClosed"
```

-

```html
<template>
  <el-dialog
    title="添加用户"
    :visible.sync="dialogVisible"
    width="30%"
    @close="addDialogClosed"
  >
    <el-form
      ref="addFormRef"
      :model="addForm"
      label-width="70px"
      :rules="addFormRules"
    >
      <el-form-item label="用户名" prop="username">
        <el-input v-model="addForm.username"></el-input>
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button @click="dialogVisible = false">取 消</el-button>
      <el-button type="primary" @click="dialogVisible = false">确 定</el-button>
    </span>
  </el-dialog>
</template>
```



表单清空问题

```
addDialogClosed() {
	this.$refs.addFormRef.resetFields()
}
```



验证手机或者邮箱，在配置规则中配置

`validator` 指定验证规则，在`data`中配置

```javascript
email: [
    { required: true, message: "请输入邮箱", trigger: "blur" },
    { validator: checkEmail, trigger: "blur" },
  ],
mobile: [
    { required: true, message: "请输入手机号", trigger: "blur" },
    { validator: checkMobile, trigger: "blur" },
  ],
```

-

```typescript
data() {
    var checkEmail = (rule, value, cb) => {
      const regEmail = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(\.[a-zA-Z0-9_-])+/
      if (regEmail.test(value)) {
        return cb()
      }
      cb(new Error('请输入合法的邮箱'))
    }
    var checkMobile = (rule, value, cb) => {
      const regMobile = /^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/
      if (regMobile.test(value)) {
        return cb()
      }
      cb(new Error('请输入合法的手机号'))
    }
}    
```

预处理

> 即：在点击确认后对表单进行预检查，看看格式对不对

只需要添加确认的方法就可以了

```typescript
addUser() {
      this.$refs.addFormRef.validate(async valid=>{
        if(!valid){
          return
        }
        const { date:res } = await this.$http.post(
          'user',this.addForm
        )
        if (res.meta.status !== 201) {
          this.$message.error('添加用户失败！')
        }
        this.$message.success('添加用户成功！')
        // 隐藏添加用户的对话框
        this.addDialogVisible = false
        // 重新获取用户列表数据
        this.getUserList()
      })
    }
```



删除用户

> 道理也很简单，就是给按钮添加事件，删除

--

```typescript
// 根据Id删除对应的用户信息
    async removeUserById(id) {
      // 弹框询问用户是否删除数据
      const confirmResult = await this.$confirm(
        '此操作将永久删除该用户, 是否继续?',
        '提示',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).catch(err => err)
      // 如果用户确认删除，则返回值为字符串 confirm
      // 如果用户取消了删除，则返回值为字符串 cancel
      // console.log(confirmResult)
      if (confirmResult !== 'confirm') {
        return this.$message.info('已取消删除')
      }
      const { data: res } = await this.$http.delete('users/' + id)
      if (res.meta.status !== 200) {
        return this.$message.error('删除用户失败！')
      }
      this.$message.success('删除用户成功！')
      this.getUserList()
    }
```





修改用户也一样，传递ID，对ID进行用户修改





### ==遇到的问题

1，`async`  的作用是什么？



## 权限模块

添加面包屑导航

```html
<!-- 面包屑导航 -->
<el-breadcrumb separator="/">
    <el-breadcrumb-item :to="{ path: '/home' }">首页</el-breadcrumb-item>
    <el-breadcrumb-item>权限管理</el-breadcrumb-item>
    <el-breadcrumb-item>权限列表</el-breadcrumb-item>
</el-breadcrumb>
```

添加卡片

```html
<el-card></el-card>
```



这里遇到了编译错误，是因为我没有把这些模块放入`div`中



获取所有的权限信息，直接写方法调用`API`就可以了，并设置为访问时自动执行

渲染所有的信息

`rightsList` 里存放的是所有的权限信息

```html
<el-card>
        <el-table :data="rightsList" border stripe>
            <el-table-column type="index"></el-table-column>
            <el-table-column label="权限名称" prop="authName"></el-table-column>
            <el-table-column label="路径" prop="path"></el-table-column>
            <el-table-column label="权限等级" prop="level">
                <template slot-scope="scope">
                    <el-tag v-if="scope.row.level === '0'">一级</el-tag>
                    <el-tag type="success" v-else-if="scope.row.level==='1'">二级</el-tag>
                    <el-tag type="warning" v-else>三级</el-tag>
                </template>
            </el-table-column>
        </el-table>
    </el-card>
```



### ==遇到的问题

```
<template slot-scope="scope">
```



这里的`scope`有什么作用



## 角色模块

首先也是设置导航，其添加角色，以及删除，修改功能和权限模块一样

重点是设置权限

获取所有的角色

```typescript
// 获取所有角色的列表
async getRolesList() {
    const { data: res } = await this.$http.get('roles')
    if (res.meta.status !== 200) {
    	return this.$message.error('获取角色列表失败')
    }
    this.rolelist = res.data
}
```

在表格中的每一个角色前设置一个展开列,用来显示

```typescript
<!-- 展开列 -->
<el-table-column type="expand">
	<template slot-scope="scope">
        <el-row :class="['bdbottom',il===0?'bdtop':'','vcenter']" 
        v-for="(item1,il) in scope.row.children" :key="item1.id">
            <!-- 渲染一级权限 -->
            <el-col :span="5">
            	<el-tag closable @close="removeRightById(scope.row, item1.id)">
                {{item1.authName}}
                </el-tag>
                 <i class="el-icon-caret-right"></i>
                    </el-col>
                    <!-- 渲染二级和三级权限 -->
                    <el-col :span="19">
                    <!-- 通过 for 循环 嵌套渲染二级权限 -->
                        <el-row :class="[i2 === 0 ? '' : 'bdtop', 'vcenter']" 
                        v-for="(item2, i2) in item1.children" :key="item2.id">
                        <el-col :span="6" >
                        <el-tag type="success" 
                            closable @close="removeRightById(scope.row, item2.id)">
                            {{item2.authName}}
                            </el-tag>
                        <i class="el-icon-caret-right"></i>
                    </el-col>
                    <el-col :span="18">
                        <el-tag type="warning" 
                        closable @close="removeRightById(scope.row, item3.id)"
                        v-for="item3 in item2.children" 
                        :key="item3.id">
                            {{item3.authName}}
                        </el-tag>
                    </el-col>
                </el-row>
            </el-col>
        </el-row>
	</template>
</el-table-column>
```



首先是要获取所有的权限

```typescript
// 展示分配权限的对话框
async showSetRightDialog(role) {
    this.roleId = role.id
    // 获取所有权限的数据
    const { data: res } = await this.$http.get('rights/tree')
    if (res.meta.status !== 200) {
        return this.$message.error('获取权限数据失败')
    }
    // 把获取到的权限数据保存到 data 中
    this.rightslist = res.data
    // 递归获取三级节点的Id
    this.getLeafKeys(role, this.defKeys)
    this.setRightDialogVisible = true
},
// 通过递归的形式，获取角色下所有三级权限的id，并保存到 defKeys 数组中
getLeafKeys(node, arr) {
    // 如果当前 node 节点不包含 children 属性，则是三级节点
    if (!node.children) {
    	return arr.push(node.id)
    }
    node.children.forEach(item => this.getLeafKeys(item, arr))
}
```



用获取的数据用树展示出来

```typescript
<!-- 树形控件 -->
<el-tree 
    :data="rightslist" 
    :props="treeProps" 
    show-checkbox node-key="id" 
    default-expand-all :default-checked-keys="defKeys" 
    ref="treeRef">
</el-tree>
<!-- :default-checked-keys 默认选中结点的ID值-->
<!-- node-key 指定id的值 -->
<!-- show-checkbox 显示可选的树结构-->
```



在选择了结点后，点击确认保存

```typescript
// 点击为角色分配权限
async allotRights() {
    const keys = [
        //这里是调用树的默认方法，获取选中的树结点，和半选的树结点
        ...this.$refs.treeRef.getCheckedKeys(),
        ...this.$refs.treeRef.getHalfCheckedKeys()
    ]
    //用逗号连接，因为API的需要
    const idStr = keys.join(',')
    const { data: res } = await this.$http.post(
        `roles/${this.roleId}/rights`,
        { rids: idStr }
    )
    if (res.meta.status !== 200) {
    	return this.$message.error('分配权限失败！')
    }
    this.$message.success('分配权限成功！')
    this.getRolesList()
    this.setRightDialogVisible = false
}
```









### 问题

```
v-for(item,li)=>里面的li是做什么的
```

