# VUE

> 部分笔记代码来源于黑马视频笔记以及官方文档



`Vue`的核心库只关注视图层，不仅易于上手，还便于与第三方库或既有项目整合

```
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
```



# mvvm

- MVC 是后端的分层开发概念； MVVM是前端视图层的概念，主要关注于 视图层分离，也就是说：MVVM把前端的视图层，分为了 三部分 Model, View , VM ViewModel
- m   model  
  - 数据层   Vue  中 数据层 都放在 data 里面
- v   view     视图   
  - Vue  中  view      即 我们的HTML页面  
- vm   （view-model）     控制器     将数据和视图层建立联系      
  - vm 即  Vue 的实例  就是 vm  

#  指令

- 本质就是自定义属性
- Vue中指定都是以 v- 开头 

##  v-cloak

- 防止页面加载时出现闪烁问题

- 也就是页面渲染后才会去加载，因为可能会出现{{msg}}这样的标签，因为页面还没加载完全

  ```html
    <style type="text/css">
    /* 
      1、通过属性选择器 选择到 带有属性 v-cloak的标签  让他隐藏
   */
    [v-cloak]{
      /* 元素隐藏    */
      display: none;
    }
    </style>
  <body>
    <div id="app">
      <!-- 2、 让带有插值 语法的   添加 v-cloak 属性 
           在 数据渲染完场之后，v-cloak 属性会被自动去除，
           v-cloak一旦移除也就是没有这个属性了  属性选择器就选择不到该标签
  		 也就是对应的标签会变为可见
      -->
      <div  v-cloak  >{{msg}}</div>
    </div>
    <script type="text/javascript" src="js/vue.js"></script>
    <script type="text/javascript">
      var vm = new Vue({
        el: '#app',
        data: {
          msg: 'Hello Vue'
        }
      });
  </script>
  </body>
  </html>
  ```
  

##  v-text

- v-text指令用于将数据填充到标签中，作用于插值表达式类似，但是没有闪动问题
- 如果数据中有HTML标签会将html标签一并输出
- 注意：此处为单向绑定，数据对象上的值改变，插值会发生变化；但是当插值发生变化并不会影响数据对象的值

```html
<div id="app">
    <!--两种形式-->
    <p v-text="msg"></p>
    <p>
        {{msg}}
    </p>
</div>
<script>
    new Vue({
        el: '#app',
        data: {
            msg: 'Hello Vue.js'
        }
    });
</script>
```

##  v-html

- 用法和v-text 相似  但是他可以**将HTML片段填充到标签中**

- 可能有安全问题, 一般只在可信任内容上使用 `v-html`，**永不**用在用户提交的内容上

- 它与v-text区别在于v-text输出的是纯文本，浏览器不会对其再进行html解析，但v-html会将其当html标签解析后输出。

  ```html
  <div id="app">
  　　<p v-html="html"></p> <!-- 输出：html标签在渲染的时候被解析 -->
      
      <p>{{message}}</p> <!-- 输出：<span>通过双括号绑定</span> -->
      
  　　<p v-text="text"></p> <!-- 输出：<span>html标签在渲染的时候被源码输出</span> -->
  </div>
  <script>
  　　let app = new Vue({
  　　el: "#app",
  　　data: {
  　　　　message: "<span>通过双括号绑定</span>",
  　　　　html: "<span>html标签在渲染的时候被解析</span>",
  　　　　text: "<span>html标签在渲染的时候被源码输出</span>",
  　　}
   });
  </script>
  ```

##  v-pre

- 显示原始信息跳过编译过程
- 跳过这个元素和它的子元素的编译过程。
- **一些静态的内容不需要编译加这个指令可以加快渲染**

```html
    <span v-pre>{{ this will not be compiled }}</span>    
	<!--  显示的是{{ this will not be compiled }}  -->

	<span v-pre>{{msg}}</span>  
     <!--   即使data里面定义了msg这里仍然是显示的{{msg}}  -->
<script>
    new Vue({
        el: '#app',
        data: {
            msg: 'Hello Vue.js'
        }
    });

</script>
```

## v-once

- 执行一次性的插值【当数据改变时，插值处的内容不会继续更新】

```html
  <!-- 即使data里面定义了msg 后期我们修改了 仍然显示的是第一次data里面存储的数据即 Hello Vue.js  -->
     <span v-once>{{ msg}}</span>    
<script>
    new Vue({
        el: '#app',
        data: {
            msg: 'Hello Vue.js'
        }
    });
</script>
```



## 双向数据绑定

- 当数据发生变化的时候，视图也就发生变化
- 当视图发生变化的时候，数据也会跟着同步变化

### v-model

- **v-model**是一个指令，限制在 `<input>、<select>、<textarea>、components`中使用

```html
 <div id="app">
      <div>{{msg}}</div>
      <div>
          当输入框中内容改变的时候，  页面上的msg  会自动更新
        <input type="text" v-model='msg'>
      </div>
  </div>
```

###   v-on

- 用来绑定事件的
-  形式如：v-on:click  缩写为 @click;

### v-on事件函数中传入参数

```html

<body>
    <div id="app">
        <div>{{num}}</div>
        <div>
            <!-- 如果事件直接绑定函数名称，那么默认会传递事件对象作为事件函数的第一个参数 -->
            <button v-on:click='handle1'>点击1</button>
            <!-- 2、如果事件绑定函数调用，那么事件对象必须作为最后一个参数显示传递，
                 并且事件对象的名称必须是$event 
            -->
            <button v-on:click='handle2(123, 456, $event)'>点击2</button>
        </div>
    </div>
    <script type="text/javascript" src="js/vue.js"></script>
    <script type="text/javascript">
        var vm = new Vue({
            el: '#app',
            data: {
                num: 0
            },
            methods: {
                handle1: function(event) {
                    console.log(event.target.innerHTML)
                },
                handle2: function(p, p1, event) {
                    console.log(p, p1)
                    console.log(event.target.innerHTML)
                    this.num++;
                }
            }
        });
    </script>
```

## 事件修饰符

- 在事件处理程序中调用 `event.preventDefault()` 或 `event.stopPropagation()` 是非常常见的需求。
- Vue 不推荐我们操作DOM    为了解决这个问题，Vue.js 为 `v-on` 提供了**事件修饰符**
- 修饰符是由点开头的指令后缀来表示的

```html
<!-- 阻止单击事件继续传播 -->
<a v-on:click.stop="doThis"></a>

<!-- 提交事件不再重载页面 -->
<form v-on:submit.prevent="onSubmit"></form>

<!-- 修饰符可以串联   即阻止冒泡也阻止默认事件 -->
<a v-on:click.stop.prevent="doThat"></a>

<!-- 只当在 event.target 是当前元素自身时触发处理函数 -->
<!-- 即事件不是从内部元素触发的 -->
<div v-on:click.self="doThat">...</div>

使用修饰符时，顺序很重要；相应的代码会以同样的顺序产生。因此，用 v-on:click.prevent.self 会阻止所有的点击，而 v-on:click.self.prevent 只会阻止对元素自身的点击。
```

## 按键修饰符

- 在做项目中有时会用到键盘事件，在监听键盘事件时，我们经常需要检查详细的按键。Vue 允许为 `v-on` 在监听键盘事件时添加按键修饰符

```html
<!-- 只有在 `keyCode` 是 13 时调用 `vm.submit()` -->
<input v-on:keyup.13="submit">

<!-- -当点击enter 时调用 `vm.submit()` -->
<input v-on:keyup.enter="submit">

<!--当点击enter或者space时  时调用 `vm.alertMe()`   -->
<input type="text" v-on:keyup.enter.space="alertMe" >

常用的按键修饰符
.enter =>    enter键
.tab => tab键
.delete (捕获“删除”和“退格”按键) =>  删除键
.esc => 取消键
.space =>  空格键
.up =>  上
.down =>  下
.left =>  左
.right =>  右

<script>
	var vm = new Vue({
        el:"#app",
        methods: {
              submit:function(){},
              alertMe:function(){},
        }
    })

</script>
```

## 自定义按键修饰符别名

- 在Vue中可以通过`config.keyCodes`自定义按键修饰符别名

```html
<div id="app">
    预先定义了keycode 116（即F5）的别名为f5，因此在文字输入框中按下F5，会触发prompt方法
    <input type="text" v-on:keydown.f5="prompt()">
</div>

<script>
	
    Vue.config.keyCodes.f5 = 116;

    let app = new Vue({
        el: '#app',
        methods: {
            prompt: function() {
                alert('我是 F5！');
            }
        }
    });
</script>
```

### v-bind

- v-bind 指令被用来响应地更新 HTML 属性
- v-bind:href    可以缩写为    :href;

```html
<!-- 绑定一个属性 -->
<img v-bind:src="imageSrc">

<!-- 缩写 -->
<img :src="imageSrc">
```

#### 绑定对象

- 我们可以给v-bind:class 一个对象，以动态地切换class。
- 注意：v-bind:class指令可以与普通的class特性共存

```html
1、 v-bind 中支持绑定一个对象 
	如果绑定的是一个对象 则 键为 对应的类名  值 为对应data中的数据 
<!-- 
	HTML最终渲染为 <ul class="box textColor textSize"></ul>
	注意：
		textColor，textSize  对应的渲染到页面上的CSS类名	
		isColor，isSize  对应vue data中的数据  如果为true 则对应的类名 渲染到页面上 

		当 isColor 和 isSize 变化时，class列表将相应的更新，
		例如，将isSize改成false，
		class列表将变为 <ul class="box textColor"></ul>
-->

<ul class="box" v-bind:class="{textColor:isColor, textSize:isSize}">
    <li>学习Vue</li>
    <li>学习Node</li>
    <li>学习React</li>
</ul>
  <div v-bind:style="{color:activeColor,fontSize:activeSize}">对象语法</div>

<sript>
var vm= new Vue({
    el:'.box',
    data:{
        isColor:true,
        isSize:true，
    	activeColor:"red",
        activeSize:"25px",
    }
})
</sript>
```

####  绑定class

```html
2、  v-bind 中支持绑定一个数组    数组中classA和 classB 对应为data中的数据

这里的classA  对用data 中的  classA
这里的classB  对用data 中的  classB
<ul class="box" :class="[classA, classB]">
    <li>学习Vue</li>
    <li>学习Node</li>
    <li>学习React</li>
</ul>
<script>
var vm= new Vue({
    el:'.box',
    data:{
        classA:‘textColor‘,
        classB:‘textSize‘
    }
})
</script>
<style>
    .box{
        border:1px dashed #f0f;
    }
    .textColor{
        color:#f00;
        background-color:#eef;
    }
    .textSize{
        font-size:30px;
        font-weight:bold;
    }
</style>
```

#### 绑定对象和绑定数组 的区别

- 绑定对象的时候 对象的属性 即要渲染的类名 对象的属性值对应的是 data 中的数据 
- 绑定数组的时候数组里面存的是data 中的数据 

#### 绑定style

```html
 <div v-bind:style="styleObject">绑定样式对象</div>'
 
<!-- CSS 属性名可以用驼峰式 (camelCase) 或短横线分隔 (kebab-case，记得用单引号括起来)    -->
 <div v-bind:style="{ color: activeColor, fontSize: fontSize,background:'red' }">内联样式</div>

<!--组语法可以将多个样式对象应用到同一个元素 -->
<div v-bind:style="[styleObj1, styleObj2]"></div>


<script>
	new Vue({
      el: '#app',
      data: {
        styleObject: {
          color: 'green',
          fontSize: '30px',
          background:'red'
        }，
        activeColor: 'green',
   		fontSize: "30px"
      },
      styleObj1: {
             color: 'red'
       },
       styleObj2: {
            fontSize: '30px'
       }

</script>
```

## 分支结构

#### v-if 使用场景

- 1- 多个元素 通过条件判断展示或者隐藏某个元素。或者多个元素
- 2- 进行两个视图之间的切换

```html
<div id="app">
        <!--  判断是否加载，如果为真，就加载，否则不加载-->
        <span v-if="flag">
           如果flag为true则显示,false不显示!
        </span>
</div>

<script>
    var vm = new Vue({
        el:"#app",
        data:{
            flag:true
        }
    })
</script>

----------------------------------------------------------

    <div v-if="type === 'A'">
       A
    </div>
  <!-- v-else-if紧跟在v-if或v-else-if之后   表示v-if条件不成立时执行-->
    <div v-else-if="type === 'B'">
       B
    </div>
    <div v-else-if="type === 'C'">
       C
    </div>
  <!-- v-else紧跟在v-if或v-else-if之后-->
    <div v-else>
       Not A/B/C
    </div>

<script>
    new Vue({
      el: '#app',
      data: {
        type: 'C'
      }
    })
</script>
```

#### v-show 和 v-if的区别

- v-show本质就是标签display设置为none，控制隐藏
  - v-show只编译一次，后面其实就是控制css，而v-if不停的销毁和创建，故v-show性能更好一点。
- v-if是动态的向DOM树内添加或者删除DOM元素
  - v-if切换有一个局部编译/卸载的过程，切换过程中合适地销毁和重建内部的事件监听和子组件

## 循环结构

#### v-for

- 用于循环的数组里面的值可以是对象，也可以是普通元素  

```html
<ul id="example-1">
   <!-- 循环结构-遍历数组  
	item 是我们自己定义的一个名字  代表数组里面的每一项  
	items对应的是 data中的数组-->
  <li v-for="item in items">
    {{ item.message }}
  </li> 

</ul>
<script>
 new Vue({
  el: '#example-1',
  data: {
    items: [
      { message: 'Foo' },
      { message: 'Bar' }
    ]，
   
  }
})
</script>
```

- **不推荐**同时使用 `v-if` 和 `v-for`
- 当 `v-if` 与 `v-for` 一起使用时，`v-for` 具有比 `v-if` 更高的优先级。

```html
   <!--  循环结构-遍历对象
		v 代表   对象的value
		k  代表对象的 键 
		i  代表索引	
	---> 
     <div v-if='v==13' v-for='(v,k,i) in obj'>{{v + '---' + k + '---' + i}}</div>
```

- key 的作用
  - **key来给每个节点做一个唯一标识**
  - **key的作用主要是为了高效的更新虚拟DOM**

```html
<ul>
  <li v-for="item in items" :key="item.id">...</li>
</ul>

```



# Vue常用特性

## 表单基本操作

- 获取单选框中的值

  通过v-model

  1、 两个单选框需要同时通过v-model 双向绑定 一个值 

  2、 每一个单选框必须要有value属性  且value 值不能一样 

  ```html
     <input type="radio" id="male" value="1" v-model='gender'>
     <label for="male">男</label>
  
     <input type="radio" id="female" value="2" v-model='gender'>
     <label for="female">女</label>
  
  <script>
      new Vue({
           data: {
               // 默认会让当前的 value 值为 2 的单选框选中
                  gender: 2,  
              },
      })
  
  </script>
  ```

- 获取复选框中的值

  通过`v-model`

  和获取单选框中的值一样 

  复选框 `checkbox` 这种的组合时   data 中的 hobby 我们要定义成数组 否则无法实现多选

  ```html
  <div>
     <span>爱好：</span>
     <input type="checkbox" id="ball" value="1" v-model='hobby'>
     <label for="ball">篮球</label>
     <input type="checkbox" id="sing" value="2" v-model='hobby'>
     <label for="sing">唱歌</label>
     <input type="checkbox" id="code" value="3" v-model='hobby'>
     <label for="code">写代码</label>
   </div>
  <script>
      new Vue({
           data: {
                  // 默认会让当前的 value 值为 2 和 3 的复选框选中
                  hobby: ['2', '3'],
              },
      })
  </script>
  ```

- 获取下拉框和文本框中的值

  通过v-model

  1、 需要给select 通过v-model 双向绑定 一个值 
  2、 每一个option 必须要有value属性  且value 值不能一样 

     <!-- multiple 支持 多选 -->

  ```html
     <div>
        <span>职业：</span>
        <select v-model='occupation' multiple>
            <option value="0">请选择职业...</option>
            <option value="1">教师</option>
            <option value="2">软件工程师</option>
            <option value="3">律师</option>
        </select>
           <!-- textarea 是 一个双标签   不需要绑定value 属性的  -->
          <textarea v-model='desc'></textarea>
    </div>
  <script>
      new Vue({
           data: {
                  // 默认会让当前的 value 值为 2 和 3 的下拉框选中
                   occupation: ['2', '3'],
               	 desc: 'nihao'
              },
      })
  </script>
  ```

## 表单修饰符

- .number  转换为数值

  - 注意点：	当开始输入非数字的字符串时，因为Vue无法将字符串转换成数值，所以属性值将实时更新成相同的字符串。即使后面输入数字，也将被视作字符串。

  

- .trim  自动过滤用户输入的首尾空白字符

  - 只能去掉首尾的 不能去除中间的空格

  

- .lazy   将input事件切换成change事件

  - .lazy 修饰符延迟了同步更新属性值的时机。即将原本绑定在 input 事件的同步逻辑转变为绑定在 change 事件上

- 在失去焦点 或者 按下回车键时才更新

  ```html
  <!-- 自动将用户的输入值转为数值类型 -->
  <input v-model.number="age" type="number">
  
  <!--自动过滤用户输入的首尾空白字符   -->
  <input v-model.trim="msg">
  
  <!-- 在“change”时而非“input”时更新 -->
  <input v-model.lazy="msg" >
  ```

##  自定义指令

- 内置指令不能满足我们特殊的需求
- Vue允许我们自定义指令

#### Vue.directive  注册全局指令

```html
<!-- 
  使用自定义的指令，只需在对用的元素中，加上'v-'的前缀形成类似于内部指令'v-if'，'v-text'的形式。 
-->
<input type="text" v-focus>
<script>
// 注意点： 
//   1、 在自定义指令中  如果以驼峰命名的方式定义 如  Vue.directive('focusA',function(){}) 
//   2、 在HTML中使用的时候 只能通过 v-focus-a 来使用 
    
// 注册一个全局自定义指令 v-focus
Vue.directive('focus', {
  	// 当绑定元素插入到 DOM 中。 其中 el为dom元素
  	inserted: function (el) {
    		// 聚焦元素
    		el.focus();
 	}
});
new Vue({
　　el:'#app'
});
</script>
```

#### Vue.directive  注册全局指令 带参数

```html
  <input type="text" v-color='msg'>
 <script type="text/javascript">
    /*
      自定义指令-带参数
      bind - 只调用一次，在指令第一次绑定到元素上时候调用

    */
    Vue.directive('color', {
      // bind声明周期, 只调用一次，指令第一次绑定到元素时调用。在这里可以进行一次性的初始化设置
      // el 为当前自定义指令的DOM元素  
      // binding 为自定义的函数形参   通过自定义属性传递过来的值 存在 binding.value 里面
      bind: function(el, binding){
        // 根据指令的参数设置背景色
        // console.log(binding.value.color)
        el.style.backgroundColor = binding.value.color;
      }
    });
    var vm = new Vue({
      el: '#app',
      data: {
        msg: {
          color: 'blue'
        }
      }
    });
  </script>
```

#### 自定义指令局部指令

- 局部指令，需要定义在  directives 的选项   用法和全局用法一样 
- 局部指令只能在当前组件里面使用
- 当全局指令和局部指令同名时以局部指令为准

```html
<input type="text" v-color='msg'>
 <input type="text" v-focus>
 <script type="text/javascript">
    /*
      自定义指令-局部指令
    */
    var vm = new Vue({
      el: '#app',
      data: {
        msg: {
          color: 'red'
        }
      },
   	  //局部指令，需要定义在  directives 的选项
      directives: {
        color: {
          bind: function(el, binding){
            el.style.backgroundColor = binding.value.color;
          }
        },
        focus: {
          inserted: function(el) {
            el.focus();
          }
        }
      }
    });
  </script>
```

##  计算属性   computed

- 模板中放入太多的逻辑会让模板过重且难以维护  使用计算属性可以让模板更加的简洁
- **计算属性是基于它们的响应式依赖进行缓存的，重复调用值一样就不会执行那个方法**
- computed比较适合对多个变量或者对象进行处理后返回一个结果值，也就是数多个变量中的某一个值发生了变化则我们监控的这个值也就会发生变化
- 计算属性与方法的区别：计算属性是基于依赖进行缓存的，而方法不缓存

```html
 <div id="app">
    <div>{{reverseString}}</div>
    <div>{{reverseString}}</div>
     <!-- 调用methods中的方法的时候  他每次会重新调用 -->
    <div>{{reverseMessage()}}</div>
    <div>{{reverseMessage()}}</div>
  </div>
  <script type="text/javascript">
    var vm = new Vue({
      el: '#app',
      data: {
        msg: 'Nihao',
        num: 100
      },
      methods: {
        reverseMessage: function(){
          console.log('methods')
          return this.msg.split('').reverse().join('');
        }
      },
      computed: {
        //  reverseString：方法名
        reverseString: function(){
          var total = 0;
          //  当data 中的 num 的值改变的时候  reverseString  会自动发生计算  
          for(var i=0;i<=this.num;i++){
            total += i;
          }
          // 这里一定要有return 否则 调用 reverseString 的 时候无法拿到结果    
          return total;
        }
      }
    });
  </script>
```

##  侦听器   watch

- 使用watch来响应数据的变化
- 一般用于异步或者开销较大的操作
- watch 中的属性 一定是data 中 已经存在的数据 
- **当需要监听一个对象的改变时，普通的watch方法无法监听到对象内部属性的改变，只有data中的数据才能够监听到变化，此时就需要deep属性对对象进行深度监听**

```html
 <div id="app">
        <div>
            <span>名：</span>
            <span>
        <input type="text" v-model='firstName'>
      </span>
        </div>
        <div>
            <span>姓：</span>
            <span>
        <input type="text" v-model='lastName'>
      </span>
        </div>
        <div>{{fullName}}</div>
    </div>

  <script type="text/javascript">
        var vm = new Vue({
            el: '#app',
            data: {
                firstName: 'Jim',
                lastName: 'Green',
                // fullName: 'Jim Green'
            },
            watch: {
                //   注意：  这里firstName  对应着data 中的 firstName 
                //   当 firstName 值 改变的时候  会自动触发 watch
                firstName: function(val) {
                    this.fullName = val + ' ' + this.lastName;
                },
                //   注意：  这里 lastName 对应着data 中的 lastName 
                lastName: function(val) {
                    this.fullName = this.firstName + ' ' + val;
                }
            }
        });
    </script>
```



##  过滤器

- Vue.js允许自定义过滤器，可被用于一些常见的文本格式化。
- 过滤器可以用在两个地方：双花括号插值和v-bind表达式。
- 过滤器应该被添加在JavaScript表达式的尾部，由“管道”符号指示
- 支持级联操作
- 过滤器不改变真正的`data`，而只是改变渲染的结果，并返回过滤后的版本
- 全局注册时是filter，没有s的。而局部过滤器是filters，是有s的

```html
  <div id="app">
    <input type="text" v-model='msg'>
      <!-- upper 被定义为接收单个参数的过滤器函数，表达式  msg  的值将作为参数传入到函数中 -->
    <div>{{msg | upper}}</div>
    <!--  
      支持级联操作
      upper  被定义为接收单个参数的过滤器函数，表达式msg 的值将作为参数传入到函数中。
	  然后继续调用同样被定义为接收单个参数的过滤器 lower ，将upper 的结果传递到lower中
 	-->
    <div>{{msg | upper | lower}}</div>
    <div :abc='msg | upper'>测试数据</div>
  </div>

<script type="text/javascript">
   //  lower  为全局过滤器     
   Vue.filter('lower', function(val) {
      return val.charAt(0).toLowerCase() + val.slice(1);
    });
    var vm = new Vue({
      el: '#app',
      data: {
        msg: ''
      },
       //filters  属性 定义 和 data 已经 methods 平级 
       //  定义filters 中的过滤器为局部过滤器 
      filters: {
        //   upper  自定义的过滤器名字 
        //    upper 被定义为接收单个参数的过滤器函数，表达式  msg  的值将作为参数传入到函数中
        upper: function(val) {
         //  过滤器中一定要有返回值 这样外界使用过滤器的时候才能拿到结果
          return val.charAt(0).toUpperCase() + val.slice(1);
        }
      }
    });
  </script>
```

####  过滤器中传递参数

```html
    <div id="box">
        <!--
			filterA 被定义为接收三个参数的过滤器函数。
  			其中 message 的值作为第一个参数，
			普通字符串 'arg1' 作为第二个参数，表达式 arg2 的值作为第三个参数。
		-->
        {{ message | filterA('arg1', 'arg2') }}
    </div>
    <script>
        // 在过滤器中 第一个参数 对应的是  管道符前面的数据   n  此时对应 message
        // 第2个参数  a 对应 实参  arg1 字符串
        // 第3个参数  b 对应 实参  arg2 字符串
        Vue.filter('filterA',function(n,a,b){
            if(n<10){
                return n+a;
            }else{
                return n+b;
            }
        });
        
        new Vue({
            el:"#box",
            data:{
                message: "哈哈哈"
            }
        })

    </script>
```





## 生命周期

- 事物从出生到死亡的过程
- Vue实例从创建 到销毁的过程 ，这些过程中会伴随着一些函数的自调用。我们称这些函数为钩子函数

#### 常用的 钩子函数

| beforeCreate  | 在实例初始化之后，数据观测和事件配置之前被调用 此时data 和 methods 以及页面的DOM结构都没有初始化   什么都做不了 |
| ------------- | ------------------------------------------------------------ |
| created       | 在实例创建完成后被立即调用此时data 和 methods已经可以使用  但是页面还没有渲染出来 |
| beforeMount   | 在挂载开始之前被调用   此时页面上还看不到真实数据 只是一个模板页面而已 |
| mounted       | el被新创建的vm.$el替换，并挂载到实例上去之后调用该钩子。  数据已经真实渲染到页面上  在这个钩子函数里面我们可以使用一些第三方的插件 |
| beforeUpdate  | 数据更新时调用，发生在虚拟DOM打补丁之前。   页面上数据还是旧的 |
| updated       | 由于数据更改导致的虚拟DOM重新渲染和打补丁，在这之后会调用该钩子。 页面上数据已经替换成最新的 |
| beforeDestroy | 实例销毁之前调用                                             |
| destroyed     | 实例销毁后调用                                               |

## 数组变异方法

- 在 Vue 中，直接修改对象属性的值无法触发响应式。当你直接修改了对象属性的值，你会发现，只有数据改了，但是页面内容并没有改变
- 变异数组方法即保持数组方法原有功能不变的前提下对其进行功能拓展

| `push()`    | 往数组最后面添加一个元素，成功返回当前数组的长度             |
| ----------- | ------------------------------------------------------------ |
| `pop()`     | 删除数组的最后一个元素，成功返回删除元素的值                 |
| `shift()`   | 删除数组的第一个元素，成功返回删除元素的值                   |
| `unshift()` | 往数组最前面添加一个元素，成功返回当前数组的长度             |
| `splice()`  | 有三个参数，第一个是想要删除的元素的下标（必选），第二个是想要删除的个数（必选），第三个是删除 后想要在原位置替换的值 |
| `sort()`    | sort()  使数组按照字符编码默认从小到大排序,成功返回排序后的数组 |
| `reverse()` | reverse()  将数组倒序，成功返回倒序后的数组                  |

### 替换数组

- 不会改变原始数组，但总是返回一个新数组

| filter | filter() 方法创建一个新的数组，新数组中的元素是通过检查指定数组中符合条件的所有元素。 |
| ------ | ------------------------------------------------------------ |
| concat | concat() 方法用于连接两个或多个数组。该方法不会改变现有的数组 |
| slice  | slice() 方法可从已有的数组中返回选定的元素。该方法并不会修改数组，而是返回一个子数组 |

### 动态数组响应式数据

- Vue.set(a,b,c)    让 触发视图重新更新一遍，数据动态起来
- a是要更改的数据 、   b是数据的第几项、   c是更改后的数据



- vm.$set(a,b,c)：这个也可以处理数组以及对象

```html
vm.$set(vm.inf,'age',12)
//给对象添加一个age属性
```



# 常用特性应用场景

## 过滤器

- Vue.filter  定义一个全局过滤器

```html
 <tr :key='item.id' v-for='item in books'>
            <td>{{item.id}}</td>
            <td>{{item.name}}</td>
     		<!-- 1.3  调用过滤器 -->
            <td>{{item.date | format('yyyy-MM-dd hh:mm:ss')}}</td>
            <td>
              <a href="" @click.prevent='toEdit(item.id)'>修改</a>
              <span>|</span>
              <a href="" @click.prevent='deleteBook(item.id)'>删除</a>
            </td>
</tr>

<script>
    	#1.1  Vue.filter  定义一个全局过滤器
	    Vue.filter('format', function(value, arg) {
              function dateFormat(date, format) {
                if (typeof date === "string") {
                  var mts = date.match(/(\/Date\((\d+)\)\/)/);
                  if (mts && mts.length >= 3) {
                    date = parseInt(mts[2]);
                  }
                }
                date = new Date(date);
                if (!date || date.toUTCString() == "Invalid Date") {
                  return "";
                }
                var map = {
                  "M": date.getMonth() + 1, //月份 
                  "d": date.getDate(), //日 
                  "h": date.getHours(), //小时 
                  "m": date.getMinutes(), //分 
                  "s": date.getSeconds(), //秒 
                  "q": Math.floor((date.getMonth() + 3) / 3), //季度 
                  "S": date.getMilliseconds() //毫秒 
                };
                format = format.replace(/([yMdhmsqS])+/g, function(all, t) {
                  var v = map[t];
                  if (v !== undefined) {
                    if (all.length > 1) {
                      v = '0' + v;
                      v = v.substr(v.length - 2);
                    }
                    return v;
                  } else if (t === 'y') {
                    return (date.getFullYear() + '').substr(4 - all.length);
                  }
                  return all;
                });
                return format;
              }
              return dateFormat(value, arg);
            })
#1.2  提供的数据 包含一个时间戳   为毫秒数
   [{
          id: 1,
          name: '三国演义',
          date: 2525609975000
        },{
          id: 2,
          name: '水浒传',
          date: 2525609975000
        },{
          id: 3,
          name: '红楼梦',
          date: 2525609975000
        },{
          id: 4,
          name: '西游记',
          date: 2525609975000
        }];
</script>
```

## 自定义指令

- 让表单自动获取焦点
- 通过Vue.directive 自定义指定

```html
<!-- 2.2  通过v-自定义属性名 调用自定义指令 -->
<input type="text" id="id" v-model='id' :disabled="flag" v-focus>

<script>
    # 2.1   通过Vue.directive 自定义指定
	Vue.directive('focus', {
      inserted: function (el) {
        el.focus();
      }
    });

</script>
```

## 计算属性

- 通过计算属性计算图书的总数
  - 图书的总数就是计算数组的长度 

```html
 <div class="total">
        <span>图书总数：</span>
     	<!-- 3.2 在页面上 展示出来 -->
        <span>{{total}}</span>
</div>

  <script type="text/javascript">
    /*
      计算属性与方法的区别:计算属性是基于依赖进行缓存的，而方法不缓存
    */
    var vm = new Vue({
      data: {
        flag: false,
        submitFlag: false,
        id: '',
        name: '',
        books: []
      },
      computed: {
        total: function(){
          // 3.1  计算图书的总数
          return this.books.length;
        }
      },
    });
  </script>

```



##  生命周期（待补）













# 组件

## 组件注册

```vue
   <!--全局组件-->
   Vue.component('组件名',{
      data: function(){
        return {
          msg:'sss'
        }
      },
      template: '<div>{{msg}}</div>'
    })
```



注意：

1，data必须是函数并且要求返回一个对象

2，组件模板必须是一个元素根

```vue
<!--这样的两个元素根就不行-->
template: '<div>{{msg}}</div><div>{{msg}}</div>'
```



3，组件模板的内容可以是模板字符串

4，组件可以重用很多次，并且每个组件的数据互不影响

5，如果组件使用驼峰命名的方式，在使用时会出错，要转换成横断线的方式，也就是必须使用横断线应用组件

6，模板中的内容可以是模板字符串

```vue
 template: 
 `
        <div>
          <button @click="handle">点击了{{count}}次</button>
          <button>测试123</button>
		   <HelloWorld></HelloWorld>
        </div>
`
```





## 局部注册

```html
  <div id="app">
      <my-component></my-component>
  </div>


<script>
    // 定义组件的模板
    var Child1 = {
      template: '<div>A custom component!</div>'
    }
    var Child2 = {
      template: '<div>A custom component!</div>'
    }
    new Vue({
      //局部注册组件  
      components: {
        // <my-component> 将只在父模板可用  一定要在实例上注册了才能在html文件中使用
        'my-component1': Child1,
        'my-component2': Child2
      }
    })
 </script>
```







## Vue组件调试工具--DevTool



## Vue组件间的传值

**父组件向子组件传值**

- 父组件发送的形式是以属性的形式绑定值到子组件身上

```html
<menu-item title='来自父组件的值'></menu-item>
或者
<menu-item :title='来自父组件的值'></menu-item>
```

- 然后子组件用属性props接收

```html
Vue.component('menu-item',{
	props: ['title'],
	template: '<div>{{title}}</div>'
})
```

- 在props中使用驼峰形式，模板中需要使用短横线的形式字符串形式的模板中没有这个限制

```html
Vue.component('menu-item',{
	props: ['titleName'],
	template: '<div>{{title}}<menu-item :titleName='来自父组件的值'></menu-item></div>'
})
```

注意：

1，props中接收的数据可以是基本数据和引用数据

2，若想props中接受的就是当前类型的数据形式，需要用引号

```html
<menu-item title='1'></menu-item>
<!--这样得到的就是String类型的1-->
<menu-item :title='1'></menu-item> 
<!--这样得到的就是Int类型的1-->
```



**子组件向父组件传值**

- 子组件用`$emit()`触发事件,

```html
Vue.component("menu-item",{
	props:
	template:`<button @click='$emit("enlarge-text", 10)'>扩大父组件中字体大小</button>`
})
```

- `$emit()`  第一个参数为 自定义的事件名称     第二个参数为需要传递的数据
- 父组件用v-on 监听子组件的事件,通过`$event`获取参数

```html
<menu-item :parr='parr' @enlarge-text='handle($event)'></menu-item>
```



**兄弟组件之间传值**

- 兄弟间的传值需要借助事件中心

```html
var hub = new Vue()
```

- 传递数据

```javascript
methods: {
        handle: function(){
          <!--2、传递数据方，通过一个事件触发hub.$emit(方法名，传递的数据) 触发兄弟组件的事件-->
          hub.$emit('jerry-event', 2);
        }
      }
```

- 接收数据

```javascript
mounted: function() {
       // 3、接收数据方，通过mounted(){} 钩子中  触发hub.$on(方法名
        hub.$on('tom-event', (val) => {
          this.num += val;
        });
      }

//也可以这样接收
<cart-list :list='list' @jerry-event='delCart($id)'></cart-list>
```

- 销毁事件，通过hub.$off()方法名销毁之后无法进行传递数据

```javascript
//4、销毁事件 通过hub.$off()方法名销毁之后无法进行传递数据  
          hub.$off('tom-event');
          hub.$off('jerry-event');
```



## 组件插槽

组件的最大特性就是复用性，而用好插槽能大大提高组件的可复用能力

- 当组件渲染的时候，这个 `<slot>` 元素将会被替换为“组件标签中嵌套的内容”。
- 插槽内可以包含任何模板代码，包括 HTML

### 匿名插槽

```html
 <alert-box>一</alert-box>
 <alert-box>二</alert-box>
 <alert-box></alert-box>
 <!--html页面上就会显示一二三-->
 <!--值得注意的是没有写内容就是调用temlate中的默认内容-->


template:`<slot>三</slot>`
 <!--也就是slot标签中没有name属性-->
```



### 具名插槽

- 具有名字的插槽 
- 使用 `<slot>` 中的 "name" 属性绑定元素
- 具名插槽的渲染顺序，完全取决于模板，而不是取决于父组件中元素的顺序

```html
<base-layout>
<!--通过slot属性来指定, 这个slot的值必须和下面slot组件得name值对应上，如果没有匹配到 则放到匿名的插槽中   --> 
      <p slot='header'>标题信息</p>
      <p>主要内容</p>
</base-layout>


<header>
	<slot name='header'></slot>
</header>
<main>
	<slot></slot>
</main>


<!--另外一种使用方式-->

<template slot='header'>
	<p>
        标题信息1
    </p>
    <p>
        标题信息2
    </p>
</template>
```



### 作用域插槽

既可以复用子组件的slot，又可以使slot内容不一致



```html
<template slot-scope='slotProps'>
        <strong v-if='slotProps.info.id==3'>
            {{slotProps.info.name}}		         
        </strong>
        <span v-else>{{slotProps.info.name}}</span>
</template>


<div>
          <li :key='item.id' v-for='item in list'>
		  <!--在子组件模板中,<slot>元素上有一个类似props传递数据给组件的写法msg="xxx"-->
		  <!--插槽可以提供一个默认内容，如果如果父组件没有为这个插槽提供了内容，会显示默认的内容,如果父组件为这个插槽提供了内容，则默认的内容会被替换掉-->
            <slot :info='item'>{{item.name}}</slot>
          </li>
</div>
```



# 前后端互交

## 接口调用方式

- `原生ajax`
- `基于jQuery的ajax`
- `fetch`
- `axios`

> HTML *DOM* 定义了访问和操作 HTML 文档的标准方法
>
> vue 很少去执行DOM操作，所以很少用ajax



```html
 <script type="text/javascript">
	var str = "---";
	$.ajax{
		url='',
		success:function(data){
			str = data;
		}
	}
	console.log(str);//打印的还是---，因为上面的是异步请求
</script>
```



## promise

- 主要解决异步深层嵌套的问题
- promise 提供了简洁的API  使得异步操作更加容易



实现方式

.then()：得到异步任务正确的结果

.catch()：获取异常信息

.finally()：成功与否都会执行（不是正式标准） 



Promise的构造函数接收一个参数，是函数，并且传入两个参数：resolve，reject， 分别表示异步操作执行成功后的回调函数和异步操作执行失败后的回调函数

```html
 <script type="text/javascript">
        var p = new Promise(function(resolve,reject){
            setTimeout(function(){
                var flag = true;
                if(flag) {
                    resolve('成功了');
                }else{
                    reject('出错了');
                }
            },100)
        });
        p.then(function(data){
            console.log(data)
        },function(data){
            # 获取异常信息,也可以是catch
            console.log(data)
          }) 
        .finally(function(){
            console.log('finished')
          });
</script>
```

发送多个AJAX请求

```html
<script type="text/javascript">
    /*
      基于Promise发送Ajax请求
    */
    function queryData(url) {
      var p = new Promise(function(resolve, reject){
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function(){
          if(xhr.readyState != 4) return;
          if(xhr.readyState == 4 && xhr.status == 200) {
            resolve(xhr.responseText);
          }else{
            reject('服务器错误');
          }
        };
        xhr.open('get', url);
        xhr.send(null);
      });
      return p;
    }
	# 注意：这里需要开启一个服务 
    # 在then方法中，你也可以直接return数据而不是Promise对象，在后面的then中就可以接收到数据了
    # 这也是针对原生多个AJAX请求太丑Promise采取的方式
    # 返回的也可以是值，而后面的then方法接受的也就是那个值，但是同样也可以继续连接下去，因为then会默认产生一个当前对象传递下去
    queryData('http://localhost:3000/data')
      .then(function(data){
        console.log(data) 
        return queryData('http://localhost:3000/data1');
      })
      .then(function(data){
        console.log(data);
        return queryData('http://localhost:3000/data2');
      })
      .then(function(data){
        console.log(data)
      });
  </script>
```



静态方法

.all()

- `Promise.all`方法接受一个数组作参数，数组中的对象（p1、p2、p3）均为promise实例（如果不是一个promise，该项会被用`Promise.resolve`转换为一个promise)

.race()

- `Promise.race`方法同样接受一个数组作参数。当p1, p2, p3中有一个实例的状态发生改变（变为`fulfilled`或`rejected`），p的状态就跟着改变。并把第一个改变状态的promise的返回值，传给p的回调函数



> 两个方法的差异就是all会等到全部执行完再回调，race会在第一个执行完就回调



## fetch

- Fetch API是新的ajax解决方案 Fetch会返回Promise
- **fetch不是ajax的进一步封装，而是原生js，没有使用XMLHttpRequest对象**。



### 基本用法

```javascript
<script type="text/javascript">
    fetch('http://localhost:3000/fdata').then(function(data){
      // text()方法返回一个Promise实例对象，用于获取后台返回的数据
      return data.text();
    }).then(function(data){
      //   在这个then里面我们能拿到最终的数据  
      console.log(data);
    })
</script>
```



### 不同的请求方式

GET

```javascript
		# GET参数传递 - 传统URL  通过url  ？ 的形式传参 
        fetch('http://localhost:3000/books?id=123', {
            	# get 请求可以省略不写 默认的是GET 
                method: 'get'
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });

      #  GET参数传递  restful形式的URL  通过/ 的形式传递参数  即  id = 456 和id后台的配置有关   
        fetch('http://localhost:3000/books/456', {
                method: 'get'
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });
```



POST

```javascript

       # POST请求传参
        fetch('http://localhost:3000/books', {
                method: 'post',
            	# 3.1  传递数据 
                body: 'uname=lisi&pwd=123',
            	#  3.2  设置请求头,必须要设置，不然无法传递
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });

       # POST请求传参
        fetch('http://localhost:3000/books', {
                method: 'post',
                body: JSON.stringify({
                    uname: '张三',
                    pwd: '456'
                }),
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });
```



DELECT

```javascript
		# DELETE请求方式参数传递
        fetch('http://localhost:3000/books/789', {
                method: 'delete'
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });
```



PUT

```javascript
		# PUT请求传参 
        fetch('http://localhost:3000/books/123', {
                method: 'put',
                body: JSON.stringify({
                    uname: '张三',
                    pwd: '789'
                }),
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(function(data) {
                return data.text();
            }).then(function(data) {
                console.log(data)
            });
```



### 响应格式

用fetch来获取数据，如果响应正常返回，我们首先看到的是一个response对象

其中包括返回的一堆原始字节，这些字节需要在收到后，需要我们通过调用方法将其转换为相应格式的数据，比如`JSON`，`BLOB`或者`TEXT`等等

```javascript
	fetch('http://localhost:3000/json').then(function(data){
      // return data.json();   //  将获取到的数据使用 json 转换对象，之后就可以直接使用对象的属性
      return data.text(); //  //  将获取到的数据 转换成字符串 ，之后需要将字符串转换为对象，然后使用
    }).then(function(data){
      // console.log(data.uname)
      // console.log(typeof data)
      var obj = JSON.parse(data);
      console.log(obj.uname,obj.age,obj.gender)
    })
```



## Axios

- 基于promise用于浏览器和node.js的http客户端
- 支持浏览器和node.js
- 支持promise
- 能拦截请求和响应
- 自动转换JSON数据
- 能转换请求和响应数据

### 基本用法

不同的请求不同的方法即可

```javascript
axios.get('http://localhost:3000/adata').then(function(ret){ 
      #  拿到ret是一个对象,所有的对象都存在 ret 的data 属性里面
      // 注意data属性是固定的用法，用于获取后台的实际数据
      console.log(ret)
    })
```

参数传递

```javascript
axios.get('http://localhost:3000/axios?id=123').then(function(ret){
      console.log(ret.data)
    })

axios.get('http://localhost:3000/axios/123').then(function(ret){
      console.log(ret.data)
    })
    
axios.get('http://localhost:3000/axios', {
      params: {
        id: 789
      }
    }).then(function(ret){
      console.log(ret.data)
    })

//put 和 psot 有点不一样

axios.post('http://localhost:3000/axios', {
      uname: 'lisi',
      pwd: 123
    }).then(function(ret){
      console.log(ret.data)
    })

var params = new URLSearchParams();
    params.append('uname', 'zhangsan');
    params.append('pwd', '111');
axios.post('http://localhost:3000/axios', params).then(function(ret){
      console.log(ret.data)
    })
```



### 全局配置

```javascript
#  配置公共的请求头 
axios.defaults.baseURL = 'https://api.example.com';
#  配置 超时时间
axios.defaults.timeout = 2500;
#  配置公共的请求头
axios.defaults.headers.common['token'] = AUTH_TOKEN;
# 配置公共的 post 的 Content-Type
axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded';
```



### 拦截器

请求拦截器

```javascript
axios.interceptors.request.use(function(config) {
      console.log(config.url)
      # 1.1  任何请求都会经过这一步   在发送请求之前做些什么   
      config.headers.mytoken = 'nihao';
      # 1.2  这里一定要return   否则配置不成功  
      return config;
    }, function(err){
       #1.3 对请求错误做点什么    
      console.log(err)
    })
```

响应拦截器

```javascript
axios.interceptors.response.use(function(res) {
      #2.1  在接收响应做些什么  
      var data = res.data;
      return data;
    }, function(err){
      #2.2 对响应错误做点什么  
      console.log(err)
    })
```





## `async`  和 `await`

```javascript
	# 1.1 async作为一个关键字放到函数前面
	async function queryData() {
      # 1.2 await关键字只能在使用async定义的函数中使用,await后面可以直接跟一个 Promise实例对象（axios和fetch返回的都是Promise对象）
      var ret = await new Promise(function(resolve, reject){
        setTimeout(function(){
          resolve('nihao')
        },1000);
      })
      
      // console.log(ret.data)
      return ret;
    }
	# 1.3 任何一个async函数都会隐式返回一个promise   我们可以使用then 进行链式编程
    queryData().then(function(data){
      console.log(data)
    })

	
```

--

```javascript
	#2.async函数处理多个异步函数
    axios.defaults.baseURL = 'http://localhost:3000';
    async function queryData() {
      # 2.1  添加await之后 当前的await 返回结果之后才会执行后面的代码     
      var info = await axios.get('async1');
      #2.2  让异步代码看起来、表现起来更像同步代码
      var ret = await axios.get('async2?info=' + info.data);
      return ret.data;
    }

    queryData().then(function(data){
      console.log(data)
    })
```



# 路由

## 概念

路由的本质就是一种对应关系，比如说我们在url地址中输入我们要访问的url地址之后，浏览器要去请求这个url地址对应的资源

那么url地址和真实的资源之间就有一种对应的关系，就是路由



## 分类

后端路由是由服务器端进行实现，并完成资源的分发

前端路由是依靠hash值(锚链接)的变化进行实现 



## Vue-Route

需要导入`vue-route`的`js文件`

### 快速上手

1，添加路由链接

```html
<div>
    <router-link to="/user">User</router-link>
    添加路由填充位（路由占位符）
    <router-view></router-view>
</div>
```

2，定义路由组件（也就是对应的url会路由到哪里去）

```javascript
var User = { template:"<div>This is User</div>" }
```

3，配置路由规则并创建路由实例

```javascript
var myRouter = new VueRouter({
    routes:[
        //每一个路由规则都是一个对象，对象中至少包含path和component两个属性
        //path表示  路由匹配的hash地址，component表示路由规则对应要展示的组件对象
        {path:"/user",component:User}
    ]
})
```

4，路由挂载到Vue实例中

```javascript
const vm = new Vue({
	el: '#app',
	router
})
```



### 嵌套路由

也就是在一个路由中再放一个路由

```javascript
routes: [
        { 
        path: "/login", 
        component: Login,
        //通过children属性为/login添加子路由规则
        children:[
            { path: "/login/account", component: account },
            { path: "/login/phone", component: phone },
                ]
        }    
        ]
```



### 动态路由

当多个URL中仅仅是后缀不同，前缀都一样的时候，可以使用动态路由

第一种

```javascript
//这样就可以针对多个/user/1 /user/2 /user/3 去路由

var User = { template:"<div>用户：{{$route.params.id}}</div>"}
routes: [
	//通过/:参数名  的形式传递参数 
	{ path: "/user/:id", component: User }
]
```

第二种

```javascript
var User = { 
    props:["username"],
    template:"<div>{{username}}</div>"
}
{ path: "/user/:id", component: User,props:true} //这样User组件那里就能获得id
{ path: "/user/:id", component: User,props:{username:"jack"} },//这样还能传递其他的参数，但是不能传递id
{ path: "/user/:id", component: User,props: route=>{username:"jack",id:$route.params.id}},//这种就能把id也传过去
```



### 命名路由

给路由取一个名字`name属性`

```javascript
<router-link :to="{ name:'user' , params: {id:123} }">User</router-link>

{ path: "/user/:id", component: User, name:"user"}
```



编程式导航

给按钮之类的组件加方法，进行导航

`this.$router.push("/login");`

```javascript
methods: {
	goDetial(id){
		console.log(id)
		this.$router.push('/userinfo'+id)
	}
}
```



## 路由的案例

> 在笔记中存放



