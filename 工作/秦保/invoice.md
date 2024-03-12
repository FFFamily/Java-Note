字段信息（5月23日版本）

```json
{
    "id": "429CEC7AB2FB433681D75227E72EE2E3", 
    "type": 1,
    "email": "56765@qq.com",
    "phone": "19835503978",
    "status": 0,
    "address": "湖南省永州市蓝山县所城镇",
    "history": [
        {
            "id": "866342B4C021485DA50AB0988C9BCB86",
            "data": {},
            "type": 5,
            "createdAt": 1684725593
        }
    ],
    "bankName": "浦发",
    "policyId": "738E4C16D38F4BE8A67E91865AE0DF31",
    "policyNo": "PGSH29M82T00",
    "accountId": "00002x001",
    "createdAt": 1684725593,
    "bankCardNo": "888888",
    "modifiedAt": 1684725593,
    "contactName": "张文昊",
    "insuranceId": "200000015",
    "invoiceName": "深圳市秦保科技有限公司",
    "invoiceType": 1,
    "orgAccountId": "00002x",
    "taxpayerCode": "91440300MA5GAK5U7E",
    "contactMobile": "19969132815",
    "endorsementId": "4E311F805EB04F3593AD1E1BA4FEE9DF",
    "endorsementNo": "2023052202",
    "contactAddress": "甘肃省嘉峪关市嘉峪关市新城镇",
  	"scanUrl":[],
  	"extraData":{},
  	"subbranch":"",
  	"taxpayerType":0,
  	"electronicUrl":"",
  	"trackNo":""
}
```

字段描述

| 字段名         | 字段描述                                                     |
| -------------- | ------------------------------------------------------------ |
| id             |                                                              |
| type           | 保单类型：0 保单 \| 1 批单                                   |
| email          | 邮箱                                                         |
| phone          | 税务登记联系电话                                             |
| status         | 发票申请状态 -1 待申请、0 已申请、1 已开票、3 保司开票中、4 开票失败、5 已报废 |
| address        | 税务登记地址                                                 |
| history        | 历史记录                                                     |
| bankName       | 开户银行名称                                                 |
| policyId       | 保单Id                                                       |
| policyNo       | 保单号                                                       |
| accountId      | 业务员Id                                                     |
| createdAt      | 创建时间                                                     |
| bankCardNo     | 银行账号(卡号)                                               |
| modifiedAt     | 更新时间（申请时间）                                         |
| contactName    | 收件人                                                       |
| insuranceId    | 险种Id                                                       |
| invoiceName    | 发票抬头(投保人)                                             |
| invoiceType    | 发票类型：0 电子普票 \| 1 纸质专票                           |
| orgAccountId   | 组织id                                                       |
| taxpayerCode   | 纳税人识别号                                                 |
| contactMobile  | 收件人联系方式                                               |
| endorsementId  | 批单Id                                                       |
| endorsementNo  | 批单号                                                       |
| contactAddress | 收件地址                                                     |
| scanUrl        | 发票扫描件                                                   |
| extraData      | 额外字段                                                     |
| subbranch      | 所在支行                                                     |
| taxpayerType   | 纳税人类型                                                   |
| electronicUrl  | 电子发票url                                                  |
| trackNo        | 快递单号                                                     |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |
|                |                                                              |

纳税人类型（taxpayerType）枚举

```
TaxpayerType: {
        境内个人: 0, // 境内个人
        小规模纳税人: 1, // 小规模纳税人
        增值税一般纳税人: 2, // 增值税一般纳税人
        非增值税纳税人: 3, // 非增值税纳税人
    },
```

历史记录

| id        | 表编号                                 |
| --------- | -------------------------------------- |
| data      | 包含 invoice 的所有内容（history除外） |
| type      | 操作类型                               |
| remark    | 备注（失败原因）                       |
| createdAt | 创建时间                               |

以下是操作类型的枚举

```
BACK(0L, "打回"),
INVOICED(1L, "确认开票"),
SCRAPPED(2L, "报废"),
CHANGE(3L, "工作人员修改申请信息"),
RESUBMIT(4L, "重新提交"),
START(5L,"发起申请"),
UPDATE(6L, "更新信息"),
WITHDRAW(7L,"撤回"),
SEND(8L,"保司开票中");
```

