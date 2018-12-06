<%@ Page Title="" Language="C#" MasterPageFile="~/請假主版.Master" AutoEventWireup="true" CodeBehind="select2_produceline.aspx.cs" Inherits="全傳請假系統.select2_produceline" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        #Table tbody tr td {
            vertical-align: middle;
        }

        .col-xs-1, .col-sm-1, .col-md-1, .col-lg-1, .col-xs-2, .col-sm-2, .col-md-2, .col-lg-2, .col-xs-3, .col-sm-3, .col-md-3, .col-lg-3, .col-xs-4, .col-sm-4, .col-md-4, .col-lg-4, .col-xs-5, .col-sm-5, .col-md-5, .col-lg-5, .col-xs-6, .col-sm-6, .col-md-6, .col-lg-6, .col-xs-7, .col-sm-7, .col-md-7, .col-lg-7, .col-xs-8, .col-sm-8, .col-md-8, .col-lg-8, .col-xs-9, .col-sm-9, .col-md-9, .col-lg-9, .col-xs-10, .col-sm-10, .col-md-10, .col-lg-10, .col-xs-11, .col-sm-11, .col-md-11, .col-lg-11, .col-xs-12, .col-sm-12, .col-md-12, .col-lg-12 {
            position: relative;
            min-height: 1px;
            padding-right: 5px;
            padding-left: 10px;
        }

        .form-horizontal .form-group {
            margin-left: 10px;
        }

        .input-group[class*="col-"] {
            padding-left: 10px;
            padding-right: 10px;
        }

        .form-horizontal .control-label {
            padding-top: 0px;
            text-align: center;
        }
    </style>
    <script type="text/javascript">



        function pageload() {
            window.location.reload();
        }


        function imageFormatter(value) {
            if (value != '' && value != null) {
                return '<a target="_blank" href="' + value + '" download>點我</a>';
            }
        }
        $(document).ready(function () {


            //nav 上的待審核按鈕是否可見
         if(  <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
        {
            if(document.getElementById("check"))
                document.getElementById("check").style.display="block";  
            if(document.getElementById("check2"))
                document.getElementById("check2").style.display="block";  
        }

            //取得users的資料
            $.ajax({
                type: 'POST',
                url: 'Tools/ddlsql.ashx?mode=users',
                dataType: 'json',
                success: function (data2) {
                    $('#users').bootstrapTable({ data: data2 });
                }
            });

            $.ajax({
                url: '/Tools/select_produceline.ashx?mode=Dept',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json'
            }).then(function (response) {
                data: $.map(response, function (obj) {
                    $("#Dept").append($("<option></option>").text(obj.CONTEN)).select2({
                        //maximumSelectionSize: 5
                    });
                    return obj;
                })
            });
            $("#Leave").select2({
                //maximumSelectionSize: 5
            });
            $.ajax({
                url: '/Tools/select_produceline.ashx?mode=User',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                cache: false,
                success: function (data) {
                    $('#UserTable').bootstrapTable({ data: data });
                }
            });

            //開啟功能
            if ("<%= Session["username"]%>" == '03009' || "<%= Session["username"]%>" == '03427') {
                $(document).keypress(function (event) {
                    if (event.keyCode == 121 || event.keyCode == 89) {
                        //y
                        document.getElementById("mis").style.display = "block";
                    }
                });
                $(document).keypress(function (event) {
                    if (event.keyCode == 78 || event.keyCode == 110) {
                        //n
                        document.getElementById("mis").style.display = "none";
                    }
                });
            }


        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
    <div id="ontopDiv" class="container">
        <ul class="nav nav-tabs">
            <li role="presentation"><a href="<%Response.Write(Session["Home"]);%>">假單申請</a></li>
            <li role="presentation"><a href="AllecDoor.aspx">打卡查詢</a></li>
            <li role="presentation" class="active"><a href="<% Response.Write(Session["select2"]);%>">假單查詢</a></li>
            <%if (Session["check1"] != null)
                {
                    Response.Write("<li role='presentation' id='check' style='display: none'><a href='" + Session["check1"] + "'>行政待審核</a></li>");

                }
                if (Session["check2"] != null)
                {
                    Response.Write("<li role='presentation' id='check2' style='display: none' ><a href='" + Session["check2"] + "'>現場待審核</a></li>");
                }
            %>
        </ul>
    </div>
    <div class="container-fluid">
        <div class="text-right">
            <asp:Label ID="Label1" runat="server" Text="登入時間"></asp:Label>
        </div>
    </div>
    <div class="container">
        <div class="form-group">
            <span style="font-size: 22px">剩餘時數</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#modalTable2">法規說明</button><br />
            <br />
            <table id="leftleave" data-select-item-name="leftleave"></table>
            <hr />
            <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12">
                <div><span>日期範圍</span></div>
                <div class="input-group col-lg-12 col-md-12 col-sm-12 col-xs-12">
                    <input id="LeaveDate" type="text" class="datepicker form-control" style="height: 32px;" name="leavedate" readonly="readonly" />
                    <span class="input-group-addon">～</span>
                    <input id="ToLeaveDate" type="text" class="datepicker form-control" style="height: 32px;" name="toleavedate" readonly="readonly" />
                </div>
            </div>
            <div id="Panel" class="col-lg-6 col-md-6 col-sm-6 col-xs-12">
                <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12">
                    <span>單位</span><br />
                    <select id="Dept" name="dept" style="width: 230px" multiple="multiple"></select>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2 col-xs-3">
                    <span>工號</span><br />
                    <input id="User" class="form-control" style="width: 80px" readonly="readonly" />
                </div>
                <div class="col-lg-1 col-md-1 col-sm-1 col-xs-3">
                    <br />
                    <button id="Select" type="button" class="btn btn-default" data-toggle="modal" data-target="#modalTable1">...</button>
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2 col-xs-3">
                    <span>姓名</span><br />
                    <input id="Name" class="form-control" style="width: 100px" readonly="readonly" />
                </div>
            </div>
            <br />
            <br />
            <br />
            <br />
            <div class="col-lg-3 col-md-3 col-sm-3 col-xs-6">
                <span>假別</span><br />
                <select id="Leave" style="width: 150px" multiple="multiple">
                    <option value="9">特休</option>
                    <option value="10">補休</option>
                    <option value="2">事假</option>
                    <option value="3">病假</option>
                    <option value="17">生理</option>
                    <option value="5">公假</option>
                    <option value="4">公傷</option>
                    <option value="6">婚假</option>
                    <option value="8">喪假</option>
                    <option value="7">產(娩)假</option>
                    <option value="16">產檢</option>
                    <option value="15">陪產</option>
                    <option value="14">無薪</option>
                    <option value="1">曠職</option>
                    <option value="11">特准</option>
                    <option value="12">出差</option>
                    <option value="13">彈性</option>
                    <option value="18">家庭照顧</option>
                    <option value="19">育嬰留停</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-2 col-sm-2 col-xs-6">
                <span>審核狀態</span>
                <select id="Approval" class="form-control" style="width: 160px">
                    <option value="-1">全部狀態</option>
                    <option value="0">已通過審核</option>
                    <option value="1">申請成功</option>
                    <option value="390">組長核准</option>
                    <option value="2">課長核准</option>
                    <option value="3">副理核准</option>
                    <option value="4">經理核准</option>
                    <option value="5">退件</option>
                </select>
            </div>
            <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 text-right">
                <br />
                <button id="Update" type="button" class="btn btn-primary" data-toggle="modal" data-target="#Updatemodal" >修改</button>&nbsp;
                <button id="Delete" type="button" class="btn btn-default" data-toggle="modal" data-target="#Deletemodal" >退件</button>&nbsp;
                <button id="Delete_2" type="button" class="btn btn-default" data-toggle="modal" data-target="#Deletemodal_2" >刪除</button>&nbsp;
                <button id="Search" type="button" class="btn btn-primary">查詢</button>&nbsp;
                <button id="Clear" type="button" class="btn btn-default">清除</button>&nbsp;
            </div>
            <br />
            <br />
            <br />
        </div>
        <!-- form-group -->
        <div style="overflow: auto" class="container">
            <div style="width: 1450px">
                <table id="SearchTable" class="table table-striped" data-toggle="table" data-pagination="true">
                    <thead>
                        <tr class="noExl">
                            <th data-field="CONTEN">部門</th>
                            <th data-field="PA60002">工號</th>
                            <th data-field="CNname">姓名</th>
                            <th data-field="PA604">假別</th>
                            <th data-field="start">請假起始日</th>
                            <th data-field="end">請假結束日</th>
                            <th data-field="time">時數</th>
                            <th data-field="PA60016">事由(備註)</th>
                            <th data-field="PA60038">職務代理人</th>
                            <th data-field="PA60040" data-formatter="imageFormatter">附件</th>
                            <th data-field="app">申請日期</th>
                            <th data-field="PA60996">keyin人員</th>
                            <th data-field="audit">審核狀態</th>
                            <th data-field="PA60042">退件原因</th>
                            <th data-field="PA60003" class="hiddencol noExl">流水號</th>
                            <th data-field="TYP" class="hiddencol noExl">Sour</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
        <br />
        <br />
        <div class="container" id="mis" style="display: none">
            <table id="users" data-search="true" data-height="430" data-pagination="true">
                <thead>
                    <tr>
                        <th data-field="username"></th>
                        <th data-field="cnname">姓名</th>
                        <th data-field="UserPwd"></th>
                        <th data-field="a1"></th>
                        <th data-field="q1"></th>
                    </tr>
                </thead>
            </table>
        </div>
        <div class="modal fade" id="modalTable1" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">人員資訊</h4>
                    </div>
                    <div class="modal-body">
                        <table id="UserTable" class="table table-striped" data-search="true" data-click-to-select="true" data-pagination="true">
                            <thead>
                                <tr>
                                    <th data-field="Username">工號</th>
                                    <th data-field="CNname">姓名</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button id="Check" type="button" class="btn btn-default" data-dismiss="modal">確認</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="modalTable2" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 70%;">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">法規說明</h4>
                    </div>
                    <div class="modal-body">
                        <table id="Table" class="table table-striped" data-toggle="table">
                            <thead>
                                <tr>
                                    <th>假別</th>
                                    <th>說明</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>特休</td>
                                    <td class="text-left">員工於本公司繼續工作滿一定期間者，本公司應依下列規定給予特別休假：<br />
                                        一：六個月以上一年未滿者，三日<br />
                                        二：一年以上二年未滿者，七日<br />
                                        三：二年以上三年未滿者，十日<br />
                                        四：三年以上五年未滿者，每年十四日<br />
                                        五：五年以上十年未滿者，每年十五日<br />
                                        六：十年以上者，每一年加給一日，加至三十日為止</td>
                                </tr>
                                <tr class="info">
                                    <td>婚假</td>
                                    <td class="text-left">員工結婚者給予婚假八日，工資照給。員工婚假應自登記結婚之日前十日起三個月內請畢，但經本公司事先同意者，得於一年內請畢。<br />
                                        婚假應於銷假上班後一個月內檢具結婚登記之戶籍謄本送人資單位存查，未提供上述證明者，其請假得改以特別休假登記，無特別休假者，改以事假登記。</td>
                                </tr>
                                <tr>
                                    <td>事假</td>
                                    <td class="text-left">員工因事必須親自處理者，得請事假；一年內合計不得超過十四日。事假期間不給工資。</td>
                                </tr>
                                <tr class="info">
                                    <td>病假</td>
                                    <td class="text-left">員工因普通傷害、疾病或生理原因必須治療或休養者，得依下列規定請普通傷病假，請假連續二日(含)以上者，需繳付醫療證明。<br />
                                        (普通傷病假一年內合計未超過三十日部分，工資折半發給，其領有勞工保險普通傷病給付未達工資半數者，由本公司補足之)<br />
                                        一、未住院者，一年內合計不得超過三十日<br />
                                        二、住院者，二年內合計不得超過一年<br />
                                        三、未住院傷病假與住院傷病假，二年內合計不得超過一年</td>
                                </tr>
                                <tr>
                                    <td>生理</td>
                                    <td class="text-left">女性員工因生理日致工作有困難者，每月得請生理假一日，全年請假日數未逾三日，不併入病假計算，其餘日數併入病假計算。<br />
                                        (請休生理假不需付證明文件，另，前開併入及不併入病假之聲裡假薪資，減半發給)。</td>
                                </tr>
                                <tr class="info">
                                    <td>喪假</td>
                                    <td class="text-left">工資照給。員工喪假得依習俗於百日內分次申請。<br />
                                        一、父母、養/繼父母、配偶喪亡者，八日<br />
                                        二、(外)祖父母、子女、配偶之父母、配偶之養父母或繼父母喪亡者，六日<br />
                                        三、(外)曾祖父母、兄弟姊妹、配偶之(外)祖父母喪亡者，三日</td>
                                </tr>
                                <tr>
                                    <td>公傷</td>
                                    <td class="text-left">員工因職業傷害而致殘廢、傷害或疾病者，其治療、休養期間，給予公傷病假。<br />
                                        員工申請公傷病假，已逾越合理之期間，或出具之診斷書經本公司認為有疑義或不客觀者，本公司得支付費用並令員工至公立醫院就醫，並由本公司依醫師開立之診斷書令員工辦理請假事宜，變更員工工作場所、更換工作或縮短工作時間，員工有接受之義務。<br />
                                        (參照內政部74年12月31日台內勞字第374520號、勞委會76年11月6日台勞動字第4763號、職業安全衛生第21條及勞工健康保護規則第15條第1項第2款)</td>
                                </tr>
                                <tr class="info">
                                    <td>產(娩)假</td>
                                    <td class="text-left">一、女性員工分娩前後，應停止工作，給予產假八星期。<br />
                                        二、妊娠三個月以上流產者，應停止工作，給予產假四星期。<br />
                                        三、第一目、第二目規定之女性員工受雇工作在六個月以上者，停止工作期間工資照給，未滿六個月者減半發給。<br />
                                        四、妊娠二個月以上未滿三個月流產者，應停止工作，給予產假一星期。<br />
                                        五、妊娠未滿二個月流產者，應停止工作，給予產假五日。<br />
                                        六、第四目、第五目規定之女性員工產假期間薪資之計算，如依勞工請假規則請普通傷病假，則就普通傷病假一年內未超三十日部分，折半發給工資。<br />
                                        如依性別工作平等法請求時，不給工資，唯不得視為缺勤而影響其全勤獎金、考績或為其他不利之處分。<br />
                                        七、女性員工請產假需提出證明文件。</td>
                                </tr>
                                <tr>
                                    <td>產檢</td>
                                    <td class="text-left">員工妊娠期間，給予產檢假五日，薪資照給。</td>
                                </tr>
                                <tr class="info">
                                    <td>陪產</td>
                                    <td class="text-left">員工於其配偶分娩時，得於配偶分娩之當日及其前後合計十五日期間內，擇其中之五日請陪產假。陪產假期間薪資照給。</td>
                                </tr>
                                <tr>
                                    <td>家庭照顧</td>
                                    <td class="text-left">員工於其家庭成員預防接種、發生嚴重之疾病或其他重大事故需親自照顧時，得請家庭照顧假；<br />
                                        其請假日數併入事假計算。家庭照顧假薪資之計算，依事假規定辦理。</td>
                                </tr>
                                <tr class="info">
                                    <td>公假</td>
                                    <td class="text-left">員工有依法令規定應給公假情事者，依實際需要天數給予公假，工資照給。<br />
                                        其教育召集者，應於教育召集結束後，於銷假上班後三日內檢具解召令送人資單位存查。<br />
                                        未提供上述證明文件者，其請假事宜，得改以特別休假或事假登記之。</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-dismiss="modal">確認</button>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="Deletemodal_2" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 300px">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">刪除假單</h4>
                    </div>
                    <div class="modal-body">
                        <h1 style="color: #FF0000; font-size: x-large; text-align: center">確定要刪除嗎?</h1>
                    </div>
                    <div class="modal-footer">
                        <button id="removebtn" type="button" class="btn btn-primary" data-dismiss="modal">確認</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>

        <div class="modal fade" id="Updatemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">修改假單</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <div class="form-group form-inline">
                                <div class="input-group" style="display: none">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">假別</label>
                                    </div>
                                    <div class="input-group col-xs-1 col-sm-1 col-lg-1 col-md-1">
                                        <select id="Leaveid2" class="form-control" name="ddl" style="width: 120px;">
                                            <option value="0" data-text="">請選擇</option>
                                            <option value="9" data-text="特休" data-id="nine">特休</option>
                                            <option value="10" data-text="補休" data-id="ten">補休</option>
                                            <option value="2" data-text="事假" data-id="two">事假</option>
                                            <option value="3" data-text="病假" data-id="three">病假</option>
                                            <option value="17" data-text="生理" data-id="oneseven">生理</option>
                                            <option value="5" data-text="公假" data-id="five">公假</option>
                                            <option value="4" data-text="公傷" data-id="four">公傷</option>
                                            <option value="6" data-text="婚假" data-id="six">婚假</option>
                                            <option value="8" data-text="喪假" data-id="eight">喪假</option>
                                            <option value="7" data-text="產(娩)假" data-id="seven">產(娩)假</option>
                                            <option value="16" data-text="產檢" data-id="onesix">產檢</option>
                                            <option value="15" data-text="陪產" data-id="onefive">陪產</option>
                                            <option value="14" data-text="無薪" data-id="onefour">無薪</option>
                                            <option value="18" data-text="家庭照顧">家庭照顧</option>
                                        </select>
                                    </div>
                                    <div class="input-group">
                                        <label id="idtext2" class="control-label"></label>
                                    </div>
                                    <div id="updeathdiv" class="input-group" style="display: none">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">天數</label>
                                        </div>
                                        <div class="input-group col-md-2">
                                            <select id="updeath" class="form-control" style="width: 120px;">
                                                <option value="0">請選擇</option>
                                                <option id="8" value="8">父母、養/繼父母、配偶喪亡者(8日)</option>
                                                <option id="6" value="6">(外)祖父母、子女、配偶之父母、配偶之養父母或繼父母喪亡者(6日)</option>
                                                <option id="3" value="3">(外)曾祖父母、兄弟姊妹、配偶之(外)祖父母喪亡者(3日)</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="input-group col-md-12" style="margin-top: 10px; display: none">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">請假日期</label>
                                    </div>
                                    <div class="input-group col-md-6">
                                        <input id="LeaveDate2" type="text" class="datepicker form-control" style="height: 32px;" name="leavedate2" readonly="readonly" />
                                        <span class="input-group-addon">～</span>
                                        <input id="ToLeaveDate2" type="text" class="datepicker form-control" style="height: 32px;" name="toleavedate2" readonly="readonly" />
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1" style="margin-left: 5px">
                                        <label for="inputl" class="control-label">時數加總</label>
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1 text-right">
                                        <input id="hr2" type="text" class="form-control w70" style="width: 57px;" value="" name="hr" readonly="readonly" />
                                    </div>
                                </div>
                                <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">事由</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-8 col-lg-8 col-md-8">
                                        <textarea id="Cause2" cols="50" rows="5" class="form-control" name="cause"></textarea>
                                    </div>
                                </div>
                            </div>
                            <div class="input-group col-md-12" style="margin-top: 10px">
                                <div class="input-group">
                                    <label for="inputl" class="control-label">上傳證明</label>
                                </div>
                                <div class="input-group col-xs-8 col-sm-6 col-lg-6">
                                    <input type="file" id="UploadedFiles2" multiple="multiple" />
                                    <span id="NewFile2"></span>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button id="update" type="button" class="btn btn-primary">確認</button>
                            <button id="close2" type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade" id="Deletemodal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 300px">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">刪除假單</h4>
                    </div>
                    <div class="modal-body">
                        <p>輸入退件的原因</p>
                        <br />
                        <br />
                        <textarea id="whynopasstext" class="form-control" style="height: 70px"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button id="Remove" type="button" class="btn btn-primary" data-dismiss="modal">確認</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script>
        $(function(){


            var CanAdvanceMode;


            (function GetSupervisor(){
                $.ajax({
                    type: 'POST',
                    url: 'Tools/select_produceline.ashx?mode=CanAdvanceMode',
                    async:false,
                    success: function (data2) {
                        CanAdvanceMode=data2;
                    }
                });         
            })()



            if(CanAdvanceMode=='1')
            {
                document.getElementById("Panel").style.display = "inline-block";
                document.getElementById("Update").style.display = "none";
                document.getElementById("Delete").style.display = "none";
                document.getElementById("Delete_2").style.display = "inline-block";
            }
            else if(CanAdvanceMode=='99')
            {
                document.getElementById("Panel").style.display = "inline-block";
                document.getElementById("Update").style.display = "inline-block";
                document.getElementById("Delete").style.display = "inline-block";
                document.getElementById("Delete_2").style.display = "inline-block";
            }
            else if(CanAdvanceMode=='10')
            {
                document.getElementById("Panel").style.display = "inline-block";
                document.getElementById("Update").style.display = "none";
                document.getElementById("Delete").style.display = "none";
                document.getElementById("Delete_2").style.display = "none";
            }
            else{
                
                document.getElementById("Panel").style.display = "none";
                document.getElementById("Update").style.display = "none";
                document.getElementById("Delete").style.display = "none";
                document.getElementById("Delete_2").style.display = "none";
            }

            $('#SearchTable').on('click-row.bs.table', function (e, row, $element) {
                $('.warning').removeClass('warning');
                $($element).addClass('warning');
                $('#Update').attr('disabled', false);
                $('#Delete').attr('disabled', false);
                $('#Delete_2').attr('disabled', false);
            });

            $('#LeaveDate, #ToLeaveDate').datetimepicker({
                format: 'yyyy-mm-dd',
                language: 'zh-TW',
                autoclose: true,
                maxView: 3,
                minView: 2
            });
            $('#LeaveDate2, #ToLeaveDate2').datetimepicker({
                format: 'yyyy-mm-dd hh:ii',
                language: 'zh-TW',
                autoclose: true,
                minuteStep: 30,
                daysOfWeekDisabled: [0, 6],
                enabledDates:_Holiday.NeedWorkHoliday
            });
            $('#LeaveDate, #LeaveDate2').datetimepicker().on('changeDate', function (ev) {
                $('#ToLeaveDate, #ToLeaveDate2').datetimepicker('setStartDate', ev.date);
            });
            /**********剩餘時數***********/
            $.ajax({
                type: 'POST',
                url: 'Tools/leftleave_produceline.ashx?mode=nine',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success: (function (nine) {
                    //特休  nine
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/leftleave_produceline.ashx?mode=ninehr',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8',
                        success: (function (ninehr) {
                            //特休的累計
                            $.ajax({
                                type: 'POST',
                                url: 'Tools/leftleave_produceline.ashx?mode=two',
                                dataType: 'json',
                                contentType: 'application/json; charset=utf-8',
                                success: (function (two) {
                                    //事假 two
                                    $(function () {
                                        test1($('#leftleave'), 3, 2);
                                    });
                                    function test1($table, cells, rows) {
                                        var i, j, row, a,
                                                columns = [],//拿來放thead的
                                                data = [],//拿來放tbody的
                                                data2 = [];//拿來將'星期0'改成出席狀況的
                                        for (i = 0; i < cells; i++) {
                                            columns.push({//宣告欄位名稱，塞入table
                                                field: i,//title的index
                                                title: '假別' + i,
                                                sortable: false//排序功能
                                            });
                                        }
                                        data2.push(columns);//先放入所有title，星期0~7
                                        var Today = Date();
                                        var qwe = Today.substring(0, 3);
                                        $.each(data2, function (i, item) {//將'星期0'改為出席狀況
                                            item[0].title = '';
                                            item[1].title = '特休';
                                            //item[2].title = '婚假';
                                            item[2].title = '事假';
                                            //item[3].title = '病假';
                                            //item[5].title = '生理';
                                            //item[6].title = '喪假';
                                            //item[7].title = '產(娩)假';
                                            //item[8].title = '產檢';
                                            //item[9].title = '陪產';
                                            //item[10].title ='家庭照顧';
                                        });
                                        //tbody
                                        for (i = 0; i < rows; i++) {
                                            row = {};
                                            for (j = 0; j < cells; j++) {
                                                row[j] = 'Row-' + i + '-' + j;
                                                //累計時數
                                                if (row[j] == 'Row-1-0') {
                                                    row[j] = '累計時數';
                                                } else if (row[j] == 'Row-1-' + j) {
                                                    if (row[j] != 'Row-1-0') {
                                                        //累計時數
                                                        if (row[j] == 'Row-1-1') {
                                                            //特 nine
                                                            if (nine.length == 0) {
                                                                row[j] = '0小時';
                                                            } else {
                                                                row[j] = nine[0].PA86011 / 60 + '小時';
                                                            }
                                                        } else if (row[j] == 'Row-1-2') {
                                                            //事 two
                                                            if (two[0].pa60011 == null) {
                                                                row[j] = '0小時'
                                                            } else {
                                                                row[j] = two[0].pa60011 + '小時';
                                                            }
                                                        } else {
                                                            row[j] = '0 小時';
                                                        }
                                                    }
                                                } else if (row[j] == 'Row-0-0') {
                                                    //剩餘時數
                                                    row[j] = '剩餘時數';
                                                } else if (row[j] == 'Row-0-1') {
                                                    //剩餘時數
                                                    if (ninehr.length == 0) {
                                                        row[j] = '0小時';
                                                    }
                                                    else if(nine[0].PA86007 != null&& ((nine[0].PA86010*1) - (nine[0].PA86011*1)) == 0){
                                                        //alert(nine[0].PA86007);
                                                        var pa8607= nine[0].PA86007;
                                                        row[j] = '0小時 ' + pa8607.substr(0,10) + '增加特休時數';
                                                    }
                                                    else {
                                                        row[j] = ninehr[0].PA86010 / 60 - nine[0].PA86011 / 60 + '小時';
                                                    }
                                                } else if (row[j] == 'Row-0-2') {
                                                    row[j] = 112 - two[0].pa60011 + '小時';
                                                } else {
                                                    row[j] = 0 + '小時';
                                                }
                                            }
                                            //將tbody寫入data
                                            data.push(row);
                                        }
                                        //寫入table
                                        $table.bootstrapTable('destroy').bootstrapTable({
                                            columns: columns,
                                            data: data,
                                            fixedColumns: true
                                        });
                                    }
                                })  /**  事假 two  **/
                            });  /**  事假 two  **/
                        })  /**  特休的累計  **/
                    });  /**  特休的累計  **/
                })  /**  特休 nine  **/
            });  /**  特休 nine  **/
            /**********剩餘時數***********/
            //登出鈕
            function logoutbtn() {
                var r = confirm("確定要登出嗎？");
                if (r == true) {
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/leaveuser_produceline.ashx?pass=logout',
                        success: function () {
                            location.href = 'Login.aspx';
                        }
                    });
                }
            }
            $('#Dept').change(function () {
                var dept = new Array();
                $(this).find(':selected').each(function () {
                    dept.push("'" + $(this).val() + "'");
                });

                $('#UserTable').bootstrapTable('refresh', {
                    cache: false,
                    contentType: 'application/json; charset=utf-8',
                    url: '/Tools/select_produceline.ashx?mode=User&dept=' + encodeURI(dept) + '&a=' + Math.random(),
                    type: 'POST',
                    async: true,
                    queryParams: { dept: JSON.stringify(dept) },
                    dataType: 'json'
                });
            });  
            $('#Check').click(function () {
                var get = getMSelectedRow($('#UserTable'));
                if (get != undefined) {
                    $('#User').val(get.Username);
                    $('#Name').val(get.CNname);
                }
            });
            $('#UserTable').on('click-row.bs.table', function (e, row, $element) {
                $('.warning').removeClass('warning');
                $($element).addClass('warning');
            });
            function getMSelectedRow(xxx) {
                var index = xxx.find('tr.warning').data('index');
                return xxx.bootstrapTable('getData')[index];
            }
            
            var leftid2;
            $('#Update').click(function () {
                var get = getMSelectedRow($('#SearchTable'));
                $('#Leaveid2').val(get.PA60004);
                $('#LeaveDate2').val(get.start.substr(0,get.start.length-3));
                $('#ToLeaveDate2').val(get.end.substr(0,get.end.length-3));
                $('#hr2').val(get.time);
                $('#Cause2').val(get.PA60016);
                //if (get.PA60004 == '8') {
                //    $('#updeathdiv').attr('style', 'display: block');
                //} else {
                //    $('#updeathdiv').attr('style', 'display: none');
                //}
                $('#Leaveid2').change(function () {
                    id = $(this).find(':selected').data('id');
                    //if (id == "eight") {
                    //    $('#updeathdiv').attr('style', 'display: block');
                    //} else {
                    //    $('#updeathdiv').attr('style', 'display: none');
                    //}
                    $.ajax({//使用者點下修改假單Show的
                        type: 'POST',
                        url: 'Tools/leftleave_produceline.ashx?mode=' + id,
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8',
                        success: (function (id2) {
                            if (id == "nine") {
                                if (id2.length != 0) {
                                    var nine2 = id2[0].PA86010 / 60 - id2[0].PA86011 / 60;
                                    $("#idtext2").html('特休 剩餘：' + nine2 + '小時');
                                    leftid2 = $("#idtext2").text();
                                } else {
                                    $("#idtext2").html('特休 剩餘：0小時');
                                    leftid2 = $("#idtext2").text();
                                }
                            } else if (id == "two") {
                                var two = 112 - id2[0].pa60011;
                                $("#idtext2").html("事假 剩餘：" + two + "小時");
                                leftid2 = $("#idtext2").text();
                            }
                        }),
                        error: (function (error3) {
                            $("#idtext2").html("");
                            leftid2 = $("#idtext2").text();
                        })
                    });
                });
                id = $('#Leaveid2').find(':selected').attr('data-id');
                $.ajax({//使用者在修改假單modal內change假別下拉Show的
                    type: 'POST',
                    url: 'Tools/leftleave_produceline.ashx?mode=' + id,
                    dataType: 'json',
                    contentType: 'application/json; charset=utf-8',
                    success: (function (id2) {
                        if (id == "nine") {
                            if (id2.length != 0) {
                                var nine2 = id2[0].PA86010 / 60 - id2[0].PA86011 / 60;
                                $("#idtext2").html('特休 剩餘：' + nine2 + '小時');
                                leftid2 = $("#idtext2").text();
                            } else {
                                $("#idtext2").html('特休 剩餘：0小時');
                                leftid2 = $("#idtext2").text();
                            }
                        } else if (id == "two") {
                            var two = 112 - id2[0].pa60011;
                            $("#idtext2").html("事假 剩餘：" + two + "小時");
                            leftid2 = $("#idtext2").text();
                        }// else if (id == "eight") {
                        //    $('#updeathdiv').attr('style', 'display: block');
                        //} else {
                        //    $('#updeathdiv').attr('style', 'display: none');
                        //}
                    }),
                    error: (function (error2) {
                        $("#idtext2").html("");
                        leftid2 = $("#idtext2").text();
                    })
                });
            });

            
            $('#Remove').click(function () {

                var get = getMSelectedRow($('#SearchTable'));
                var deletebtn = get.PA60003;
                var pa60002 = get.PA60002;
                var id = get.PA60004;
                var from = get.PA60007 || get.start;
                var to = get.PA60008 || get.end;
                var hr = get.PA60011 / 60;
                var cause = get.PA60016;
                var pa39 = get.audit;


                var nopasstext = document.getElementById("whynopasstext").value;
                $.ajax({
                    type: 'POST',
                    async:false,
                    url: 'Tools/leaveuser_produceline.ashx?pass=HRdelete&deletebtn=' + deletebtn + '&pa60002=' + pa60002 + '&id=' + id + '&from=' + from + '&to=' + to + '&hr=' + hr + '&cause=' + encodeURI(cause) + '&name=' + name + '&pa39=' + encodeURI(pa39) + '&nopass=' +encodeURI(nopasstext) ,
                    success:(function (data) {
                        location.href = '<% Response.Write(Session["select2"]);%>';
                    })
                });
            });
            

            $('#removebtn').click(function(){

                var get = getMSelectedRow($('#SearchTable'));
                var id = get.PA60003;
                var user = get.PA60002;
                var TYP=get.TYP;

                $.ajax({
                    type: 'POST',
                    async:false,
                    url: 'Tools/leaveuser_produceline.ashx?pass=HRdelete_2&id=' + id + '&user=' + user+'&TYP='+TYP ,
                    success:(function (data) {
                        if(data!=''){
                            alert(data);
                            $('#Search').trigger('click');//觸發重新refresh
                        }
                    })
                });
            }); 


            $('#Search').click(function () {
                $('#Update').attr("disabled", true);
                $('#Delete').attr("disabled", true);
                var dept = new Array();
                $('#Dept').find(':selected').each(function () {
                    dept.push("'" + $(this).val() + "'");
                });
                var approval = $('#Approval').val() || "-1";
                var user = $('#User').val() || "";
                var leavedate = $('#LeaveDate').val();
                var toleavedate = $('#ToLeaveDate').val();
                var leave = $('#Leave').val() || [];
                var param = { dept: JSON.stringify(dept), approval: approval, user: user, leavedate: leavedate, toleavedate: toleavedate, leave: leave };
                var url1 = '/Tools/select_produceline.ashx?mode=Search';
                $('#SearchTable').bootstrapTable('refresh', {
                    cache: false,
                    contentType: 'application/json; charset=utf-8',
                    url: url1 + "&dept=" + encodeURI(dept) + "&approval=" + approval + "&user=" + user + "&leavedate=" + leavedate + "&toleavedate=" + toleavedate + "&leave=" + leave + "&a=" + Math.random(),
                    type: 'POST',
                    async: true,
                    queryParams: param,
                    dataType: 'json'
                });
            });
            $('#Clear').click(function () {
                var dept = "";
                $('#UserTable').bootstrapTable('refresh', {
                    cache: false,
                    contentType: 'application/json; charset=utf-8',
                    url: '/Tools/select_produceline.ashx?mode=User&dept=' + dept + '&a=' + Math.random(),
                    type: 'POST',
                    async: true,
                    queryParams: { dept: JSON.stringify(dept) },
                    dataType: 'json'
                });
                $('#Dept').select2("val", "");
                $('#Approval').val("-1");
                $('#User').val("");
                $('#Name').val("");
                $('#LeaveDate').val("");
                $('#ToLeaveDate').val("").datetimepicker("setStartDate");
                $('#Leave').select2("val", "");
                $('#SearchTable').bootstrapTable("removeAll");
                $('#Update').attr("disabled", true);
                $('#Delete').attr("disabled", true);
            });
            //使用者申請時間檢查是否重複
            function CheckCondition(Data, from_time, to_time) {//這行 主要function
                var result = Data.every(function (i, e) {
                    var a;
                    var b;
                    var e;
                    var f;
                    var g;
                    var c =  Date.parse(i.PA60007);//Date.parse => 轉秒數
                    var d = Date.parse(i.PA60008);
                    if (from_time > c && from_time < d) {
                        a = false;
                    } else {
                        a = true;
                    }
                    if (to_time > c && to_time < d) {
                        b = false;
                    } else {
                        b = true;
                    }
                    if (from_time < c && c < to_time) {
                        e = false;
                    } else {
                        e = true;
                    }
                    if (from_time < d && d < to_time) {
                        f = false;
                    } else {
                        f = true;
                    }
                    if ((from_time.toLocaleString() == d.toLocaleString() && to_time.toLocaleString() == c.toLocaleString()) || (from_time.toLocaleString() == c.toLocaleString() && to_time.toLocaleString() == d.toLocaleString())) {
                        g = false;
                    } else {
                        g = true;
                    }
                    if (a == false || b == false || e == false || f == false || g == false)
                        return false;
                    else
                        //只有 a & b 都是  true 才可以傳回去
                        //( 選定的時間都不在區間內才可以傳回 true )
                        return true;
                })
                return result;
            }
            $('#UploadedFiles2').on('change', function () {
                $('#NewFile2').html(null);
                for (var i = 0; i < this.files.length; i++) {
                    if (this.files.length > 1) {
                        $('#NewFile2').append(this.files[i].name + '<br />');
                    }
                }
            });
            $('#Updatemodal').mousedown(function(){
                tlf();
            });
            $('#update').click(function () {
                var get = getMSelectedRow($('#SearchTable'));
                var searchtableindex;
                var user = get.PA60002;
                var water = get.PA60003;
                var user60003 = get.PA60003;
                var id2 = document.getElementById("Leaveid2").value;
                var from2 = document.getElementById("LeaveDate2").value;
                var to2 = document.getElementById("ToLeaveDate2").value;
                var hr2 = document.getElementById("hr2").value;
                var cause2 = document.getElementById("Cause2").value;
                var pa39 = get.audit;
                var death = document.getElementById("updeath").value;
                var updeath = "";
                var fileUpload = $("#UploadedFiles2").get(0);
                var files = fileUpload.files;
                var data1 = new FormData();
                for (var i = 0; i < files.length; i++) {
                    data1.append(files[i].name, files[i]);
                }
                var CoDpath = upload2(data1, id2, user);
                if (id2 == 0 || from2 == "" || to2 == "" || cause2 == "") {
                    alert('請重新填寫假單，尚有未填寫的欄位，全部皆為必填欄位。');
                } else if (hr2 == 0 || hr2 < 0) {
                    alert('請重新填寫起迄時間，起迄時間區間有誤。');
                } else {
                    var d = new Date(from2.substr(5, 2) + '/' + from2.substr(8, 2) + '/' + from2.substr(0, 4) + ' ' + from2.substr(11, 5));
                    var b = new Date(to2.substr(5, 2) + '/' + to2.substr(8, 2) + '/' + to2.substr(0, 4) + ' ' + to2.substr(11, 5));
                    var from_time2 = Date.parse(d);
                    var to_time2 = Date.parse(b);
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/leaveuser_produceline.ashx?pass=gender',
                        dataType: 'json',
                    }).success(function (gender) {
                        //時間區段判斷
                        $.ajax({
                            type: 'POST',
                            url: 'Tools/leaveuser_produceline.ashx?pass=datecheck2&user60003=' + user60003 + '&pa39=' + pa39,
                            dataType: 'json',
                        }).success(function (datecheck2) {
                            var result = CheckCondition(datecheck2, from_time2, to_time2);//這行
                            if (result == true) {
                        
                                $.ajax({
                                    async: false,
                                    url: 'Tools/leaveuser_produceline.ashx?pass=HRupdate&gender=' + gender[0].PA51008 + '&user=' + user + '&water=' + water + '&id2=' + id2 + '&from2=' + from2 + '&to2=' + to2 + '&hr2=' + hr2 + '&cause2=' + encodeURI(cause2) + '&pa39=' + pa39 + '&updeath=' + updeath + '&death=' + death + '&CoDpath=' + CoDpath,
                                    type: 'POST',
                                    dataType: 'json',   
                                    contentType: 'application/json; charset=utf-8'
                                }).success(function (response) {
                                    if(response=='NotLoggin'){
                                        alert('登入時效已超過，請重新登入!!')
                                        location.href="Login.aspx";
                                    }else{
                                    
                                        //alert('更新成功!!');
                                        $.each($('#SearchTable').bootstrapTable('getData'),function(i,row){
                                            searchtableindex = $('#SearchTable').find('tr.warning').data('index');
                                        })
                                        $('#SearchTable').bootstrapTable('updateRow', {
                                            index: searchtableindex, row: response.Table[0]
                                        });
                                        $("#Updatemodal").modal('hide');
                                        $('#Update').attr('disabled', 'disabled');
                                        $('#Delete').attr('disabled', 'disabled');
                                        $('#Delete_2').attr('disabled', 'disabled');
                                    }
                                }).error(function (data) {
                             
                                });
                            } else {
                           
                                alert('您選擇的時段區間已有假單');
                            }
                        });
                    });
                }
            });
            function upload2(data, id2, user) {
                var path;
                $.ajax({
                    type: "post",
                    url: "Tools/leaveuser_produceline.ashx?pass=HRupload&id=" + id2 + "&user=" + user,
                    contentType: "application/json; charset=utf-8",
                    data: data,
                    async: false,
                    contentType: false,
                    processData: false,
                    success: function (pathx) {
                        path = pathx;
                    },
                    error: function (err) { alert(err.statusText); }
                });
                return path;
            }      
        
        })



    </script>
</asp:Content>
