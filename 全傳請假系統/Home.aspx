<%@ Page Title="" Language="C#" MasterPageFile="~/請假主版.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="全傳請假系統.WebForm1" %>


<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <style>
        #Span {
            color: red;
        }

        .col-xs-1, .col-sm-1, .col-md-1, .col-lg-1,
        .col-xs-2, .col-sm-2, .col-md-2, .col-lg-2,
        .col-xs-3, .col-sm-3, .col-md-3, .col-lg-3,
        .col-xs-4, .col-sm-4, .col-md-4, .col-lg-4,
        .col-xs-5, .col-sm-5, .col-md-5, .col-lg-5,
        .col-xs-6, .col-sm-6, .col-md-6, .col-lg-6,
        .col-xs-7, .col-sm-7, .col-md-7, .col-lg-7,
        .col-xs-8, .col-sm-8, .col-md-8, .col-lg-8,
        .col-xs-9, .col-sm-9, .col-md-9, .col-lg-9,
        .col-xs-10, .col-sm-10, .col-md-10, .col-lg-10,
        .col-xs-11, .col-sm-11, .col-md-11, .col-lg-11,
        .col-xs-12, .col-sm-12, .col-md-12, .col-lg-12 {
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

    <%--<marquee></marquee>--%><%--自動滾動--%>
    <div class="container" id="ontopDiv">
        <ul class="nav nav-tabs">
            <li role="presentation" class="active"><a href="<%Response.Write(Session["Home"]);%>">假單申請</a></li>
            <li role="presentation"><a href="AllecDoor.aspx">打卡查詢</a></li>
            <li role="presentation"><a href="<% Response.Write(Session["select2"]);%>">假單查詢</a></li>
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
    <div class="container-fluid text-right">
        <asp:Label ID="Label19" runat="server" Text="登入時間"></asp:Label>
    </div>
    <br />
    <%--            <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12"
            <div class=" text-left">

   <div class="container">
        <!--原本申請假單等按鈕放的位置-->
    </div>
         </div>
            </div> 
                <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12">
            <div class=" text-right">

           </div>
        </div>--%>




    <div class="container">

        <!-- ***************************************** 新增開始 ******************************************* -->

        <div class="modal fade" id="insertmodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">申請假單</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <%--如果把-fluid拿掉 modal body 內容會跑掉--%>
                            <div class="form-group form-inline">
                                <div class="input-group">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">假別</label>
                                    </div>
                                    <div class="input-group col-xs-1 col-sm-1 col-lg-1 col-md-1">
                                        <select name="ddl" class="form-control" id="leaveid" style="width: 120px;">
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
                                            <option value="1" data-text="曠職" data-id="one">曠職</option>
                                            <%--<option value="11" data-text="特准">特准</option>--%>
                                            <%--<option value="12" data-text="出差">出差</option>--%>
                                            <%--<option value="13" data-text="彈性">彈性</option>--%>
                                            <option value="18" data-text="家庭照顧">家庭照顧</option>
                                            <%--<option value="19" data-text="育嬰留停">育嬰留停</option>--%>
                                        </select>
                                    </div>
                                    <div class="input-group">
                                        <label id="idtext" class="control-label"></label>
                                    </div>
                                    <div id="indeathdiv" class="input-group" style="display: none">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">天數</label>
                                        </div>
                                        <div class="input-group col-md-2">
                                            <select id="indeath" class="form-control" style="width: 120px;">
                                                <option value="0">請選擇</option>
                                                <option id="in8" value="8">父母、養/繼父母、配偶喪亡者(8日)</option>
                                                <option id="in6" value="6">(外)祖父母、子女、配偶之父母、配偶之養父母或繼父母喪亡者(6日)</option>
                                                <option id="in3" value="3">(外)曾祖父母、兄弟姊妹、配偶之(外)祖父母喪亡者(3日)</option>
                                            </select>
                                        </div>
                                        <div id="inHundred" class="input-group col-md-4">

                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">訃聞日期</label>
                                            <input type="text" class="form-control" style="height: 32px" id="Hundred" readonly="readonly" />

                                        </div>
                                    </div>
                                </div>
                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">請假日期</label>
                                    </div>
                                    <div class="input-group col-md-6">
                                        <input type="text" class="datepicker form-control" style="height: 32px;" id="leavedate" name="leavedate" readonly="readonly" />
                                        <span class="input-group-addon">～</span>
                                        <input id="toleavedate" class="datepicker form-control" style="height: 32px;" name="toleavedate" type="text" readonly="readonly" />
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1" style="margin-left: 5px">
                                        <label for="inputl" class="control-label">時數加總</label>
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1 text-right">
                                        <input type="text" class="form-control w70" style="width: 57px;" value="" id="hr" name="hr" readonly="readonly" /><%--單位:小時    --%>
                                    </div>
                                </div>
                                <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">事由</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-8 col-lg-8 col-md-8">
                                        <textarea id="cause" name="cause" placeholder="限制 20 中文字" cols="50" rows="5" class="form-control"></textarea>
                                    </div>
                                </div>

                                <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">職務代理人</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-6 col-lg-6">
                                        <select id="jobagent" class="form-control" style="width: 170px; height: 35px"></select>
                                    </div>
                                </div>
                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">上傳證明</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-6 col-lg-6">
                                        <input type="file" id="uploadedFiles" />
                                        <span id="newfile"></span>
                                    </div>
                                </div>
                                <hr />
                                <div class="input-group col-xs-12 col-sm-12 col-lg-12 text-center">
                                    ↓選擇簽核主管↓
                                </div>
                                <hr />

                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div id="chieftitle">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">課長</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="chief" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <div id="level2title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">單位主管</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="level2" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <div id="level1title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">部門主管</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="level1" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <%--<div id="leader1title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">組長</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="leader" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>--%>
                                </div>
                                <div id="bossone" class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">總經理&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                    </div>
                                    <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                        <select class="id2 form-control" style="width: 170px;">
                                            <option>李進勝</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <!-- form-group -->
                        </div>
                        <!-- container-fluid -->


                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" id="insert">確認</button>
                            <button type="button" class="btn btn-default" id="close" data-dismiss="modal">關閉</button>
                        </div>
                        <!-- modal-footer -->
                    </div>
                    <!-- modal-body -->
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->

        <!-- ***************************************** 新增結束 ******************************************* -->


        <!-- ***************************************** 刪除開始 ******************************************* -->

        <div class="modal fade" id="modal2" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
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
        <!-- /.modal -->

        <!-- ***************************************** 刪除結束 ******************************************* -->

        <!-- ***************************************** 修改開始 ******************************************* -->

        <div class="modal fade" id="updatemodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
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
                                <div class="input-group">
                                    <div class="input-group" style="display: none">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">假別</label>
                                    </div>
                                    <div class="input-group col-xs-1 col-sm-1 col-lg-1 col-md-1" style="display: none">
                                        <select name="ddl" class="form-control" id="leaveid2" style="width: 120px;">
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
                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">請假日期</label>
                                    </div>
                                    <div class="input-group col-md-6">
                                        <input type="text" class="datepicker form-control" style="height: 32px;" id="leavedate2" name="leavedate" readonly="readonly" />
                                        <span class="input-group-addon">～</span>
                                        <input id="toleavedate2" class="datepicker form-control" style="height: 32px;" name="toleavedate2" type="text" readonly="readonly" />
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1" style="margin-left: 5px">
                                        <label for="inputl" class="control-label">時數加總</label>
                                    </div>
                                    <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1 text-right">
                                        <input type="text" class="form-control w70" style="width: 57px;" value="" id="hr2" name="hr" readonly="readonly" />
                                    </div>
                                </div>
                                <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">事由</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-8 col-lg-8 col-md-8">
                                        <textarea id="cause2" name="cause" cols="50" placeholder="限制 20 中文字" rows="5" class="form-control"></textarea>
                                    </div>
                                </div>

                                <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">職務代理人</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-6 col-lg-6">
                                        <select id="jobagent2" class="form-control" style="width: 170px; height: 35px"></select>
                                    </div>
                                </div>
                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">上傳證明</label>
                                    </div>
                                    <div class="input-group col-xs-8 col-sm-6 col-lg-6">
                                        <input type="file" id="uploadedFiles2" />
                                        <span id="newfile2"></span>
                                    </div>
                                </div>
                                <hr />
                                <div class="input-group col-xs-12 col-sm-12 col-lg-12 text-center">
                                    ↓選擇簽核主管↓
                                </div>
                                <hr />

                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div id="upchieftitle">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">課長</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="upchief" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <div id="uplevel2title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">單位主管</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="uplevel2" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <div id="uplevel1title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">部門主管</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="uplevel1" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
                                    <%-- <div id="upleader1title">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">組長</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="upleader" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>--%>
                                </div>
                                <div id="upbossone" class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">總經理&nbsp;&nbsp;&nbsp;&nbsp;</label>
                                    </div>
                                    <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                        <select class="id2 form-control" style="width: 170px;">
                                            <option>李進勝</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <!-- form-group -->
                        </div>
                        <!-- container-fluid -->

                        <div class="modal-footer">
                            <button type="button" class="btn btn-primary" id="update">確認</button>
                            <button type="button" class="btn btn-default" id="close2" data-dismiss="modal">關閉</button>
                        </div>
                        <!-- modal-footer -->
                    </div>
                    <!-- modal-body -->
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->

        <!-- ***************************************** 修改結束 ******************************************* -->

        <!-- ***************************************** 審核狀態開始 ******************************************* -->
        <div class="modal fade" id="processmodal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 75%">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">審核狀態</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <div class="form-group" id="processtitle">
                                <div id="process11" class="col-lg-2 col-md-2 col-sm-2" style="display: none">
                                    <h4 id="process1">未申請假單</h4>
                                </div>

                                <div class="col-lg-1 col-md-1 col-sm-1">
                                    <span id="span1" class="glyphicon glyphicon-arrow-right" style="font-size: x-large; display: none"></span>
                                </div>

                                <div id="process22" class="col-lg-2 col-md-3 col-sm-2" style="display: none">
                                    <h4 id="process2">二階主管尚未回覆...</h4>
                                </div>

                                <div class="col-lg-1 col-md-1 col-sm-1">
                                    <span id="span2" class="glyphicon glyphicon-arrow-right" style="font-size: x-large; display: none"></span>
                                </div>

                                <div id="process33" class="col-lg-3 col-md-2 col-sm-3" style="display: none">
                                    <h4 id="process3">最高級主管尚未回覆...</h4>
                                </div>

                                <div class="col-lg-1 col-md-1 col-sm-1">
                                    <span id="span3" class="glyphicon glyphicon-arrow-right" style="font-size: x-large; display: none"></span>
                                </div>

                                <div id="process44" class="col-lg-2 col-md-2 col-sm-2" style="display: none">
                                    <h4 id="process4">總經理尚未回覆...</h4>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                        </div>
                        <!-- modal-footer -->
                    </div>
                    <!-- modal-body -->
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->
        <!-- ***************************************** 審核狀態結束 ******************************************* -->


        <div class="container">
            <div class=" btn-group">
                <button id="btn" type="button" class="btn btn-primary" data-toggle="modal" data-placement="left" title="點此完成假單申請" data-target="#insertmodal">申請假單</button>
                <button id="checkupdate" type="button" class="btn btn-default" data-toggle="modal" data-placement="left" title="請在下方選擇一筆假單予以修改" data-target="#updatemodal" disabled="disabled">修改假單</button>
                <button id="delete" type="button" class="btn btn-default" data-toggle="modal" data-placement="left" title="請在下方選擇一筆假單予以刪除" data-target="#modal2" disabled="disabled">刪除假單</button>
            </div>
            <br />
            <br />
            <h3>審核中</h3>
            <div style="overflow: auto">
                <div style="width: 1150px">
                    <table id="user"
                        data-select-item-name="update"
                        data-click-to-select="true"
                        data-row-style="rowStyle">
                    </table>
                </div>
            </div>
        </div>
    </div>

    <script>
        //nav 上的待審核按鈕是否可見
        if( <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
        {
            if(document.getElementById("check"))
                document.getElementById("check").style.display="block";  
            if(document.getElementById("check2"))
                document.getElementById("check2").style.display="block";  
        }

        $('#insertmodal').mousedown(function(){
            var time1 = $('#leavedate').val() || '';
            var time2 = $('#toleavedate').val() || '';
            var Alternative = $('#Alternative_Hugh').val() || '';

            if (time1 != "" && time2 != "") {
                var url = 'Tools/datetime.ashx?mode=time&time1=' + time1 + '&time2=' + time2;
                
                url = Alternative != '' ? url + '&Alternative=' + Alternative : url;

                $.ajax({
                    type: 'POST',
                    url: url,
                    async:false,
                    success: function (response) {
                        $('#hr').val(response);
                        $('#hr2').val(response);
                    }
                });

                //判斷總經理開啟
                var hr = $('#hr').val() *1 ;
                if (hr > 24 || <%= Convert.ToInt32(Session["PAAK200"])%> < 39) {
                    $('#bossone').css('display', 'block')
                } else {
                    $('#bossone').css('display', 'none')
                }
            }
        });

        if (<%= Convert.ToInt32(Session["PAAK200"])%> < 49 && <%= Convert.ToInt32(Session["PAAK200"])%> != 20) {
            document.getElementById("bossone").style.display = "black";
            document.getElementById("upbossone").style.display = "black";
        } else {
            document.getElementById("bossone").style.display = "none";
            document.getElementById("upbossone").style.display = "none";
        }
        if ("<%= Session["PADF"]%>" == "留職停薪") {
            $('#btn').attr('disabled', 'disabled');
        }
        var leftid,leftid2;
        //箭頭
        function process(water){
            var process1,process2,process3,process4;
            processremove();//每次進來先重置
            //alert(water);
            $.ajax({//判斷有無審核中的假單
                type:'POST',
                url:'Tools/process.ashx?mode=aprocess&water='+water,
                dataType:'json',
                contentType:'application/json; charset=utf-8',
                success:(function(data){
                    if(data.length != 0){//判斷data有無資料
                        $('#processtitle').attr('style','display:block');
                        if(data[0].PA60011 > 1440 )
                        {
                            $('#span3').attr('style','font-size: x-large;display:block');

                            $('#process44').attr('style','display:block');
                        }
                        //主管請假，直接給總經理
                        if(<%= Convert.ToInt32(Session["PAAK200"]) %> < 48 )
                        {
                            if(data[0].PA60039 == 1)
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process33').attr('style','display:block');

                                $('#span3').attr('style','font-size: x-large;display:block');

                                $('#process44').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 3)
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 通過');
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');

                                $('#span3').attr('style','font-size: x-large;display:block');

                                $('#process44').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 5)
                            {

                                $('#process1').text('假單退件');
                                $('#process1').attr('style','color:red');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 退件');
                                $('#process2').attr('style','color:red');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 退件');
                                $('#process3').attr('style','color:red');
                                $('#process33').attr('style','display:block');

                                $('#span3').attr('style','font-size: x-large;display:block');
                                $('#span3').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向

                                $('#process44').attr('style','display:block');
                                $('#process4').text('總經理 退件');
                                $('#process4').attr('style','color:red');
                                
                                //寫入文中、將pa60041改成1(代表User已看過)
                                if(data[0].PA60041 != 1){
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }
                            }
                            else//data[0].PA60039 == 0
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 通過');
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');


                                if(data[0].PA60011 > 1440 )
                                {

                                    $('#process4').text('總經理 通過');
                                    $('#process4').attr('style','color:green');

                                }  
                                if(data[0].PA60041 != 1){
                                    //寫入文中、將pa60043改成1
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }

                            }
                        }
                        else//一般人員請假
                        {
                            
                            if(data[0].PA60039 == 1)
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process33').attr('style','display:block');
                            }
                            else if(data[0].PA60039 == 2||data[0].PA60039 == 3)
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process33').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 4)
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 通過');
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 5)
                            {
                                $('#process1').text('假單退件');
                                $('#process1').attr('style','color:red');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 退件');
                                $('#process2').attr('style','color:red');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 退件');
                                $('#process3').attr('style','color:red');
                                $('#process33').attr('style','display:block');
                                if(data[0].PA60011 > 1440 )
                                {
                                    $('#span3').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向

                                    $('#process4').text('總經理 退件');
                                    $('#process4').attr('style','color:red');

                                }
                                if (data[0].PA60041 != 1){
                                    //寫入文中、將pa60041改成1(代表User已看過)
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }
                            }
                            else//data[0].PA60039 == 0
                            {
                                $('#process1').text('申請成功');
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').text('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process3').text('最高級主管 通過');
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');


                                if(data[0].PA60011 > 1440 )
                                {

                                    $('#process4').text('總經理 通過');
                                    $('#process4').attr('style','color:green');

                                }  
                                if(data[0].PA60041 != 1){
                                    //寫入文中、將pa60043改成1
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }

                            }

                        }//判斷是一般人員請假還是主管請假

                    }//data.length != 0

                })//success

            });//ajax aprocess

        }//function process(water)
        function processremove(){
            $('#process1').text('未申請假單');
            $('#process1').attr('style','color:black');
            //$('#process11').attr('style','display:none');
            $('#span1').attr('class','glyphicon glyphicon-arrow-right');//箭頭重置
            //$('#span1').attr('style','display:none');

            $('#process2').text('二階主管尚未回覆...');
            $('#process2').attr('style','color:black');
            //$('#process22').attr('style','display:none');
            $('#span2').attr('class','glyphicon glyphicon-arrow-right');//箭頭重置
            //$('#span2').attr('style','display:none');

            $('#process3').text('最高級主管尚未回覆...');
            $('#process3').attr('style','color:black');        
            //$('#process33').attr('style','display:none');
            $('#span3').attr('class','glyphicon glyphicon-arrow-right');//箭頭重置
            $('#span3').attr('style','display:none');

            $('#process4').text('總經理尚未回覆...');
            $('#process4').attr('style','color:black');
            $('#process44').attr('style','display:none');            
        }
        var Hundred = 1;//判斷是否還需要填寫訃聞時間，0→要，1→不需要
        var Hundredtime = '';

        $('#leaveid').change(function () {
            //id = $(this).find(':selected').data('id');
            //或是以下方式也可以
            id = $(this).find(':selected').attr('data-id');
            var indeath = null;
            //判斷是否選擇喪假
            if (id == "eight") {
                Hundred = 0;
                $('#indeathdiv').attr('style','display:block');
                //判斷資料庫裡有無喪假之剩餘時數
                $.ajax({
                    type:'POST',
                    url:'Tools/process.ashx?mode=deathtwice',
                    async: false,
                    success:(function(data){
                        //判斷禁用選項
                        if(data == '8')
                        {
                            $('#in6').attr('disabled','disabled');
                            $('#in3').attr('disabled','disabled');
                            $('#inHundred').attr('style','display:none');
                            Hundred = 1;
                            Hundredtime = '';
                        }
                        else if(data == '6')
                        {
                            $('#in8').attr('disabled','disabled');
                            $('#in3').attr('disabled','disabled');
                            $('#inHundred').attr('style','display:none');
                            Hundred = 1;
                            Hundredtime = '';
                        }
                        else if(data == '3')
                        {
                            $('#in8').attr('disabled','disabled');
                            $('#in6').attr('disabled','disabled');
                            $('#inHundred').attr('style','display:none');
                            Hundred = 1;
                            Hundredtime = '';
                        }
                    })
                });
            }else{
                $('#indeathdiv').hide(500).attr('style','display:none');
            }
            if(id != 'eight'){//2018_01_18 碩
                //特休
                $.ajax({
                    type:'POST',
                    url:'Tools/leftleave.ashx?mode=' + id + '&insert=false',
                    dataType:'json',
                    contentType:'application/json; charset=utf-8',
                    success:(function(id2){ 

                        if (id == "nine") {
                            if(id2.length != 0){
                                var nine2 = id2[0].PA86010/60-id2[0].PA86011/60;
                                $("#idtext").html('特休 剩餘：' + nine2 + '小時');
                                leftid = $("#idtext").text();


                                if(nine2<=0&&id2[0].PA86007 != undefined){
                                    var next = id2[0].PA86007;
                                    //new Date(from.substr(5,2)+'/'+from.substr(8,2)+'/'+from.substr(0,4)+' '+from.substr(11,5));
                                    var next9 = next.substr(0,10);
                                
                                    $("#idtext").html('在'+next9+'新增特休時數，期間內另請他種假別。');
                                    leftid = $("#idtext").text();
                                }
                            }else{
                                $("#idtext").html('特休 剩餘：0小時');
                                leftid = $("#idtext").text();
                            }
                        
                        }
                        else if(id=="ten"){
                            $('#idtext').html('補休 剩餘 : ' +id2.rest+ '小時');
                            leftid = $("#idtext").text();
                        }
                        else if (id == "two") {
                            var two = 112-id2[0].pa60011;
                            $("#idtext").html("事假 剩餘：" + two + "小時");
                            leftid = $("#idtext").text();
                        } 
                        else {
                            $("#idtext").html("");
                            leftid = $("#idtext").text();
                        }

                    }),
                    error:(function(error){
                        $("#idtext").html("");
                        leftid = $("#idtext").text();
                    })
                });
            }else if(id == 'eight'){
                var typeid;
                //喪假剩餘時數   
                var a = $('#indeath').val();
                
                if(a == '0'){//2018_01_18 碩，天數下拉還沒change的時候，就等change才執行
                    $('#indeath').change(function(){                         
                        typeid = $('#indeath option:selected').val();                   
                        $.ajax({
                            type:'POST',
                            url:'Tools/leftleave.ashx?mode=' + id+'&type='+typeid,
                            success:(function(data){
  
                                if(data == 'false'){
                                    $("#idtext").html("喪假 剩餘：申請假單之後，將為您計算");
                                    leftid = 'false';
                                }else if(data == 0){                            
                                    $("#idtext").html("喪假 剩餘：" + data + "小時，煩請通知您的主管進行審核");
                                    leftid = $("#idtext").text();
                                }else{                            
                                    $("#idtext").html("喪假 剩餘：" + data + "小時");
                                    leftid = $("#idtext").text();
                                }                             
                            }),error:(function(error){
                                $("#idtext").html("");
                                leftid = $("#idtext").text();
                            })
                        });
                    });
                }else{//2018_01_18 碩，如果已經change過就直接帶目前selected的值
                    $.ajax({
                        type:'POST',
                        url:'Tools/leftleave.ashx?mode=' + id+'&type='+a,
                        success:(function(data){
                            if(data == 'false'){
                                $("#idtext").html("喪假 剩餘：申請假單之後，將為您計算");
                                leftid = 'false';
                            }else if(data == 0){                            
                                $("#idtext").html("喪假 剩餘：" + data + "小時，煩請通知您的主管進行審核");
                                leftid = $("#idtext").text();
                            }else{                            
                                $("#idtext").html("喪假 剩餘：" + data + "小時");
                                leftid = $("#idtext").text();
                            }                             
                        }),error:(function(error){
                            $("#idtext").html("請重新登入");
                            leftid = $("#idtext").text();
                        })
                    });
                }                    
            }
        });//leaveid.change


        $('#uploadedFiles').on('change', function () {
            $('#newfile').html(null);
            $('#alreadyfile').html(null);
            for (var i = 0; i < this.files.length; i++) {
                if(this.files.length > 1){
                    $('#newfile').append(this.files[i].name + '<br>');
                }
            }

        });

       
        $('#Hundred').datetimepicker({
            format: 'yyyy-mm-dd',
            language: 'zh-TW',
            maxView: 3,
            minView: 2,
            autoclose: true,
        });
        $('#leavedate, #toleavedate,#leavedate2,#toleavedate2').datetimepicker({
            format: 'yyyy-mm-dd hh:ii',
            //use24hours: true,
            language: 'zh-TW',
            autoclose: true,
            daysOfWeekDisabled: [0, 6],
            enabledDates:_Holiday.NeedWorkHoliday,
            //maxView: 3,
            //minView: 2,
            ////minView: 'month',
            minuteStep: 30
        });
        $('#leavedate,#leavedate2').datetimepicker().on('changeDate', function (ev) {
            $('#toleavedate,#toleavedate2').datetimepicker('setStartDate', ev.date);
        });
        $('#insert').click(function () {
            var id = document.getElementById("leaveid").value;
            var from = document.getElementById("leavedate").value;
            var to = document.getElementById("toleavedate").value;
            var hr = document.getElementById("hr").value;
            var cause = document.getElementById("cause").value;
            var name = document.getElementById("jobagent").value;
            var death = document.getElementById("indeath").value;
            var jobuser = name.split(" / ");
            var typetime = death*8;

            var indeath,indeathtime,a;//新增喪假的分鐘數//indeathtime為將indeath轉小時
            if (id == '8')
            {
                if(death == '0')
                {
                    alert('尚未選擇天數');
                }
                else 
                {
                    $.ajax({
                        type:'POST',
                        url:'Tools/process.ashx?mode=DeathIgt&type='+death+'&hr='+hr+'&from='+from+"&Hundred="+($('#Hundred').val()||null),
                        async:false,
                        success:(function(data){
                            if(data == 'igt'){
                                alert('此筆假單的時數 已超過 您所選擇天數別之總時數'+typetime+'小時，煩請更改喪假時數');
                            }  
                            else if(data == 'typeover'){
                                alert('待審中的喪假總時數已達到上限'+death+'日，煩請您聯繫您的主管，將假單進行審核後，再進行申請');
                            }
                            else if(data=='hundredover'){
                                alert('請假日期 起訖 超過訃聞日期 100 日，請重新選擇請假日期 起訖 !');
                            }
                            else if(data == 'timeleft over1'){
                                $.ajax({
                                    type:'POST',
                                    url:'Tools/leftleave.ashx?mode=eight&type='+death,
                                    async:false,
                                    success:function(data2){
                                        alert('此筆假單的時數 已超過 您的剩餘時數'+data2+'小時，煩請更改喪假時數');
                                    }
                                });
                            }else if(data == 'timeleft over2'){
                                alert('此筆假單的時數 已超過 您的可請時數，煩請更改申請時數');
                            }
                            else if(data == 'true')
                            {
                                insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser[0]);
                            }else{
                                alert('以上皆非');
                            }
                        })
                    });          
                }
            }
            else
            {
                insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser[0]);
            }

        });//insert click


        //------------------查看目前 Session 狀況-----------------
        //data [目前 Session 資料] - 按下申請假單按鈕(#btn) 觸發
        $('#btn').click(function(){
        
            $.ajax({
                type:'POST',
                url:'Tools/leaveuser.ashx?pass=CheckSession',
                async:false,
                cache:false,
                success:(function(data){

                })
            });             
        
        })



        function insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser){
            $('#insert').attr('disabled', true);

            var ten;
            if(id == '10'){
                ten = tenhr(from);
            }

            var fileUpload = $("#uploadedFiles").get(0);
            var files = fileUpload.files;
            var data1 = new FormData();
            for (var i = 0; i < files.length; i++) {
                data1.append(files[i].name, files[i]);
            }
            if(Hundred == 0){
                Hundredtime = $('#Hundred').val();
            }
            var up = uptime(from, to);
            var CoDpath = upload(data1,id);
            if (id == 0 || from == "" || to == "" || cause == "" || name == 0) {
                alert('尚有未填寫的欄位，有紅色星星標示皆為必填欄位。');
            }else if(id == 8 && Hundred == 0 && Hundredtime == ''){
                alert('尚未填寫訃聞日期。');
            } 
            else if (hr == 0 || hr < 0) {
                alert('請重新填寫起迄時間，起迄時間有誤。');
            } 
            else if(leftid&&leftid != "" && leftid.substring(12,leftid.length) == '新增特休時數，期間內另請他種假別'){
                alert('您的特休時數會在' + leftid.substring(10,leftid.length)+ '增加，目前尚無時數可請。' );
            }
            else if(leftid&&leftid != "" && leftid.substring(6,leftid.length-2) - hr < 0)
            {
                var sum = leftid.substring(6,leftid.length-2) - hr < 0;
                alert('您的' + leftid.substring(0,2) + '時數不夠囉！');
            }
            else if(ten&&(hr>ten.rest==true)){
                alert('補休時數不足。');
            }
            else if(up == 'from <8'){
                alert('您是8點上班，則8點以前無需請假。');
            }else if(up == 'to >17'){
                alert('您是5點下班，則5點後即無需請假。');
            }else if(up == 'from <9'){
                alert('您是9點上班，則9點以前無需請假。');
            }else if(up == 'to >18'){
                alert('您是6點下班，則6點後即無需請假。');
            }else if(up == 'from <830'){
                alert('您是8點30分上班，則8點30分以前無需請假。');
            }else if(up == 'to >1730'){
                alert('您是5點30分下班，則5點30分後即無需請假。');
            }

                //else if(leftid == "" || parseInt(leftid.match(/[0-9]+/g)) - hr >= 0 || leftid=='false') {
            else if(leftid == "" || parseFloat(leftid.match(/[0-9]{0,10}\.[0-9]{0,10}|[0-9]+/g)) - hr >= 0 || leftid=='false') {
                $('#insert').attr('disabled', true);


                var d = new Date(from.substr(5,2)+'/'+from.substr(8,2)+'/'+from.substr(0,4)+' '+from.substr(11,5));
                var b = new Date(to.substr(5,2)+'/'+to.substr(8,2)+'/'+to.substr(0,4)+' '+to.substr(11,5));
                var from_time = Date.parse(d);
                var to_time = Date.parse(b);

                $.ajax({
                    type:'POST',
                    url:'Tools/leaveuser.ashx?pass=gender',
                    dataType:'json',
                }).success(function(gender){
                
            
                    //時間區段判斷
                    $.ajax({
                        type:'POST',
                        url:'Tools/leaveuser.ashx?pass=datecheck',
                        dataType:'json',
                    }).success(function(datecheck){
                        
                        
                        //var result = this.CheckCondition($.grep(Helper.data, function (i, e) { return (i.Room == $scope.Room.areavalue && i.id != $scope.Current_ID); }), s_time, e_time);//這行
                        var result = CheckCondition(datecheck, from_time, to_time);//這行
                        if(result == true)
                        {
                            console.log('result成功');
                            $.ajax({
                                async: false,
                                url: 'Tools/leaveuser.ashx?pass=insert&gender=' + gender[0].PA51008 + '&id=' + id + '&from=' + from + '&to=' + to + '&hr=' + hr + '&cause=' + encodeURIComponent(cause) + '&name=' + encodeURI(name) +'&death='+death+'&CoDpath='+CoDpath+'&Hundredtime='+Hundredtime+'&jobuser='+jobuser,
                                type: 'POST',
                                
                                contentType: 'application/json; charset=utf-8'
                            }).success(function (response) {
                                if(response == "False"){
                                    alert('男士不可請 產檢、產(娩)、生理假 喔！');
                                }else if(response == '40'){
                                    alert('事由字數最高上限為40字喔~');
                                }else if(response == 'dateout'){
                                    alert("請假規定必須在當月份完成請假流程，已小於本月月初！");

                                }else if(response == 'weekend'){
                                    alert('您是行政人員，六日不用上班，請重新選擇日期');
                                }else if(response == 'National holidays'){
                                    alert('您請假的日子裡有國定假日，請重新選擇日期。');
                                }else if(response == "images not"){
                                    alert("您選擇的假別需上傳證明，您是否缺少上傳資料呢？");
                                }else if(response == "not jpg"){
                                    alert("上傳證明資料必須為圖片檔(.png、.jpg、.gif)、PDF檔(.pdf)。");
                                }else if(response == "生理超過次數"){
                                    alert("您已經申請過生理假，此假別一個月只能申請一次。");
                                }else if(response == "生理假只能請一天"){
                                    alert("您好！請假產生錯誤。原因：請生理假只能單月請一天，您請假時數大於一天，請重新選擇時間！謝謝。");
                                }else if(response == "General Manager" && <%= Convert.ToInt32(Session["PAAK200"])%> > 49){
                                    alert("您已申請超過連續三天，將交由總經理簽核。");
                                    console.log("OK");
                                    location.href='Home.aspx';
                                }else{
                                    console.log("OK");
                                    location.href='Home.aspx';
                                }
                                $('#insert').attr('disabled', false);
                            }).error(function (data) {                            

                            })
}
else
{

    alert('您選擇的時段區間已有假單');
}
                
                    });
                });
}

    $('#insert').attr('disabled', false);

}//insert function
function tenhr(from){
    var ten;
    $.ajax({
        type:'POST',
        async:false,
        url:'Tools/leftleave.ashx?mode=ten'+'&from='+from,
        contentType: 'application/json; charset=utf-8'
        //dataType:'json',
    }).success(function(hr){
        ten = JSON.parse(hr);
    });
    return ten;
}
function uptime(from , to){
    var Gettime;
    $.ajax({
        type:'POST',
        async:false,
        url:'Tools/leaveuser.ashx?pass=uptime&from='+from+'&to='+to,
        contentType: 'application/json; charset=utf-8'
        //dataType:'json',
    }).success(function(time){
        Gettime = time;
    });
    return Gettime;
}


//使用者申請時間檢查是否重複
function CheckCondition(Data, from_time, to_time) {//這行 主要function

    var result = Data.every(function (i, e) {
        var a;
        var b;
        var e;
        var f;
        var g;
        var c =  Date.parse(i.pa60007);//Date.parse => 轉秒數
        var d = Date.parse(i.pa60008);

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
            e = true
        }
        if (from_time < d && d < to_time) {
            f = false;
        } else {
            f = true
        }
        if ((from_time.toLocaleString() == d.toLocaleString() && to_time.toLocaleString() == c.toLocaleString()) || (from_time.toLocaleString() == c.toLocaleString() && to_time.toLocaleString() == d.toLocaleString())
        ) {
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
    }
    )

    return result;
}

function upload(data, num) {
    var path;
    $.ajax({
        type: "post",
        url: "Tools/leaveuser.ashx?pass=upload&id="+num,
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
$('#close').click(function(){
    $('#leaveid').val("0");
    $('#idtext').text("");
    $('#indeath').val("0");
    $('#leavedate').val("");
    $('#toleavedate').val("").datetimepicker("setStartDate");
    $('#hr').val("");
    $('#cause').val("");
    $('#jobagent').val("0");
    $('#newfile').val("");
    $('#uploadedFiles').val("");
    $('#indeathdiv').attr("style", "display: none");
    if (<%= Convert.ToInt32(Session["PAAK200"])%> > 49) {
        $('#bossone').attr("style", "display: none");
        $('#upbossone').attr("style", "display: none");
    }
});
$(document).ready(function () {
    //nav 上的待審核按鈕是否可見
        if(  <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
    {
        if(document.getElementById("check"))
            document.getElementById("check").style.display="block";  
        if(document.getElementById("check2"))
            document.getElementById("check2").style.display="block";  
    }

    //單位主管
    $.ajax({
        async: false,
        url: 'Tools/leaveuser.ashx?pass=level2',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#level2').append($('<option></option>').text(obj.CNname));
            $('#uplevel2').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });
    //部門主管
    $.ajax({
        async: false,
        url: 'Tools/leaveuser.ashx?pass=level1',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#level1').append($('<option></option>').text(obj.CNname));
            $('#uplevel1').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });

    //組長
    $.ajax({
        async: false,
        url: 'Tools/leaveuser.ashx?pass=leader',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#leader').append($('<option></option>').text(obj.CNname));
            $('#upleader').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });
    //課長
    $.ajax({
        async: false,
        url: 'Tools/leaveuser.ashx?pass=chief',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#chief').append($('<option></option>').text(obj.CNname));
            $('#upchief').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });
    //等文中籍職更改後即可修回此段 48~38
    if (<%= Convert.ToInt32(Session["PAAK200"])%> <= 48 && <%= Convert.ToInt32(Session["PAAK200"])%> >= 35 )
    {
        //登入為課長or副理
        document.getElementById("check").style.display="block";  //待審按鈕開啟

        //課長or副裡不用看到自己以下的簽核
        document.getElementById("level2title").style.display="none";  //隱藏單位主管(二階主管)
        document.getElementById("uplevel2title").style.display="none";
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        document.getElementById("upchieftitle").style.display="none"; //隱藏課長
        
        //抓部門主管的值
        var level1 = $('#level1').text();
        var uplevel1 = $('#uplevel1').text();
        if(level1 == "")
        {
            //沒有部門主管，就總經理出現
            document.getElementById("level1title").style.display="none";  //隱藏部門主管(一階主管)
            document.getElementById("bossone").style.display="block";  //總經理開啟
            document.getElementById("uplevel1title").style.display="none";  //隱藏部門主管(一階主管)
            document.getElementById("upbossone").style.display="block";  //總經理開啟

        }else{
            document.getElementById("level1title").style.display="block";  //開啟部門主管(一階主管)
            document.getElementById("bossone").style.display="none";  //總經理隱藏
            document.getElementById("uplevel1title").style.display="block";  //開啟部門主管(一階主管)
            document.getElementById("upbossone").style.display="none";  //總經理隱藏
        }
            
            
    } 
        //等文中籍職更改後即可修回此段 39~10
    else if(<%= Convert.ToInt32(Session["PAAK200"])%> < 35 && <%= Convert.ToInt32(Session["PAAK200"])%> >= 10 )
    {
<%--        //登入為最高級主管
        if(<%= Convert.ToInt32(Session["PAAK200"])%> != 20){
            document.getElementById("check").style.display="block";  //待審按鈕開啟
        }else{
            document.getElementById("check").style.display="none";  //待審按鈕隱藏
        }--%>

        //最高級只要看到總經理簽核
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        document.getElementById("level2title").style.display="none";  //隱藏單位主管(二階主管)
        document.getElementById("level1title").style.display="none";  //隱藏部門主管(最高級主管)
        document.getElementById("bossone").style.display="block";  //總經理開啟

        //document.getElementById("upleadertitle").style.display="none"; //隱藏組長
        document.getElementById("upchieftitle").style.display="none"; //隱藏課長
        document.getElementById("uplevel2title").style.display="none";  //隱藏單位主管(二階主管)
        document.getElementById("uplevel1title").style.display="none";  //隱藏部門主管(最高級主管)
        document.getElementById("upbossone").style.display="block";  //總經理開啟


    }
    else if(<%= Convert.ToInt32(Session["PAAK200"])%> == 1)
    {
        //登入為總經理
        document.getElementById("check").style.display="block";  //待審按鈕開啟

        //document.getElementById("leadertitle").style.display="none"; //隱藏組長
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        document.getElementById("level2title").style.display="none";
        document.getElementById("level1title").style.display="none";
        document.getElementById("bossone").style.display="none";

        //document.getElementById("upleadertitle").style.display="none"; //隱藏組長
        document.getElementById("upchieftitle").style.display="none"; //隱藏課長
        document.getElementById("uplevel2title").style.display="none";
        document.getElementById("uplevel1title").style.display="none";
        document.getElementById("upbossone").style.display="none";

    }
    else{

        var level2 = $('#level2').text(); //取單位主管的文字
        var level1 = $('#level1').text(); //取部門主管的文字

        var chief = $('#chief').text(); //取課長的文字

        if(level2 == ""){
            document.getElementById("level2title").style.display="none";
            document.getElementById("uplevel2title").style.display="none";
        }
        if(level1 == ""){
            document.getElementById("level1title").style.display="none";
            document.getElementById("uplevel1title").style.display="none";
        }
        if(chief == ""){
            document.getElementById("chieftitle").style.display="none";
            document.getElementById("upchieftitle").style.display="none";
        }
    }


    //審核中(個人)
    $.ajax({
        type: "POST",
        url: "Tools/leaveuser.ashx?pass=user",
        dataType: 'json',
        contentType: 'application/json; charset=utf-8',
        success: function (data) {
            $('#user').bootstrapTable({ data: data,
                columns:[
                        {radio: true,class:'hiddencol'},
                        {field:'PA60002',title:'工號'},
                        {field:'CNname',title:'姓名'},
                        {field:'PA604',title:'假別'},
                        {field:'datefrom',title:'請假起始日'},
                        {field:'dateto',title:'請假結束日'},
                        {field:'PA60016',title:'事由'},
                        {field:'PA60038',title:'職務代理人'},
                        {field:'hrtime',title:'時數'},
                        {field:'PA60003',title:'流水號',class:'hiddencol'},
                        {field:'PA60039',title:'流程狀況',class:'hiddencol'},
                        {field:'PA60042',title:'退件原因'}, 
                        {field: 'PA60040', title:'附件', 
                            formatter: function (value, row) {
                                if(value != '' && value != 'undefined'){                             
                                    return '<a target="_blank" href="'+value+'" download>點我</a>';
                                }
                            }//formatter                                                                   
                        },
                        {field:'PA60003',title:'審核狀態',
                            formatter:function(value){
                                return'<button id="processbtn" type="button" class="btn btn-default" data-toggle="modal" onclick="process('+value+')" data-target="#processmodal">查看</button>';
                            }
                        },
                        {field:'PA60044',title:'天數別',class:'hiddencol'},
                        {field:'PA60047',title:'訃聞日期',class:'hiddencol'}
                ]
            });
        }
    });
 
    //職代
    $.ajax({
        type: 'POST',
        url: 'Tools/leaveuser.ashx?pass=jobagent',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (data) {
        $('#jobagent').empty().append($('<option></option>').val('0').text('請選擇'));
        data: $.map(data, function (obj) {
            $('#jobagent').append($('<option></option>').val(obj.name).text(obj.name));
        });

    });

});

//======================================更新================================================

//======================================修改按鈕資料帶入-開始===============================================
        
$('#user').on('click-row.bs.table', function (e, row, $element) {
    $('.warning').removeClass('warning');
    $($element).addClass('warning');
});
function getMSelectedRow(xxx) {
    var index = xxx.find('tr.warning').data('index');
    return xxx.bootstrapTable('getData')[index];
}


//======================================修改按鈕資料帶入-結束===============================================

//======================================修改、刪除按鈕解鎖-開始===============================================
$('#user').on('click-row.bs.table', function () {
    var get = getMSelectedRow($('#user'));
    if (get.PA60039 != 0 && get.PA60039 != 5) {
        $('#checkupdate').attr('disabled', false);
        $('#delete').attr('disabled', false);
    } else {
        $('#checkupdate').attr('disabled', true);
        $('#delete').attr('disabled', true);
    }
});
//======================================修改、刪除按鈕解鎖-結束===============================================
function rowStyle(row, index) {
    if (row.PA60039 == 5) {
        return {
            classes: 'danger'
        };
    }
    return {};
}

        
$('#checkupdate').click(function () {
    var get = getMSelectedRow($('#user'));
    $('#leaveid2').val(get.PA60004);
    $('#leavedate2').val(get.PA60007.split('T')[0] + ' ' + get.PA60007.split('T')[1].substring(0, 5));
    $('#toleavedate2').val(get.PA60008.split('T')[0] + ' ' + get.PA60008.split('T')[1].substring(0, 5));
    $('#hr2').val(get.hrtime);
    $('#cause2').val(get.PA60016);
    $('#jobagent2').val(get.PA60038);
    //或是以下方式也可以
    //document.getElementById("update").style.display="initial";
    //
    if (get.PA60004 == '8') {
        $('#updeathdiv').attr('style','display:block');
        $('#updeath').val(get.PA60044);
        $.ajax({//18_01_16 碩，天數上鎖
            type:'POST',
            url:'Tools/process.ashx?mode=deathtwice',
            async: false,
            success:(function(data){
                //判斷禁用選項
                if(data == '8')
                {
                    $('#6').attr('disabled','disabled');
                    $('#3').attr('disabled','disabled');
                    $('#inHundred').attr('style','display:none');
                }
                else if(data == '6')
                {
                    $('#8').attr('disabled','disabled');
                    $('#3').attr('disabled','disabled');
                    $('#inHundred').attr('style','display:none');
                }
                else if(data == '3')
                {
                    $('#8').attr('disabled','disabled');
                    $('#6').attr('disabled','disabled');
                    $('#inHundred').attr('style','display:none');
                }
            })
        });
        //喪假剩餘時數                   
        id = $('#leaveid2').find(':selected').data('id');
        $.ajax({
            type:'POST',
            async:false,
            url:'Tools/leftleave.ashx?mode=eightupdate&type='+get.PA60044+'&water='+get.PA60003,
            success:(function(data){
                if(data == 'false'){
                    $("#idtext2").html("喪假 剩餘：尚無剩餘時數");
                    leftid2 = 'false';
                }else if(data == 0){         
                    $("#idtext2").html("喪假 剩餘：" + data + "小時，煩請通知您的主管進行審核");
                    leftid2 = $("#idtext2").text();
                }else{                            
                    $("#idtext2").html("喪假 剩餘：" + data + "小時");
                    leftid2 = $("#idtext2").text();
                }            
            }),error:(function(error){
                $("#idtext2").html("請重新登入");
                leftid2 = $("#idtext2").text();
            })
        });        
    }else{
        $('#updeathdiv').attr('style','display:none');
    }
    if ($('#hr2').val() <= 24 && <%= Convert.ToInt32(Session["PAAK200"])%> > 49) {
        $('#upbossone').attr('style', 'display:none');
    }
    $('#leaveid2').change(function(){
        id = $(this).find(':selected').data('id');
        if (id == "eight") {
            $('#updeathdiv').attr('style','display:block');
        }else{
            $('#updeathdiv').attr('style','display:none');
        }
        if(id != 'eight'){//18_01_17 碩，因選擇其他假別時，id2[0].PA86010就會取取不到直
            $.ajax({//使用者點下修改假單SHOW的
                type:'POST',
                url:'Tools/leftleave.ashx?mode=' + id + '&type=' + get.PA60044,
                dataType:'json',
                async:false,
                contentType:'application/json; charset=utf-8',
                success:(function(id2){ 
                    
                    if (id == "nine") {
                        if(id2.length != 0){
                            var nine2 = id2[0].PA86010/60-id2[0].PA86011/60;
                            $("#idtext2").html('特休 剩餘：' + nine2 + '小時');
                            leftid2 = $("#idtext2").text();
                        }else{
                            $("#idtext2").html('特休 剩餘：0小時');
                            leftid2 = $("#idtext2").text();
                        }                        
                    }
                    else if(id =="ten"){
                        $('#idtext2').html('補休 剩餘 : ' +id2.rest+ '小時');
                        leftid2 = $("#idtext2").text();
                    }
                    else if (id == "two") {
                        var two = 112-id2[0].pa60011;
                        $("#idtext2").html("事假 剩餘：" + two + "小時");
                        leftid2 = $("#idtext2").text();
                    }
                }),
                error:(function(error3){
                    $("#idtext2").html("");
                    leftid2 = $("#idtext2").text();
                })
            });     
        }
        else if(id == 'eight'){//18_01_17 碩
            $.ajax({
                type:'POST',
                async:false,
                url:'Tools/leftleave.ashx?mode=eightupdate&type='+get.PA60044+'&water='+get.PA60003,
                success:(function(data){
                    if(data == 'false'){
                        $("#idtext2").html("喪假 剩餘：申請假單之後，將為您計算");
                        leftid2 = 'false';
                    }else if(data == 0){         
                        $("#idtext2").html("喪假 剩餘：" + data + "小時，煩請通知您的主管進行審核");
                        //leftid2 = $("#idtext2").text(); 這個加了，會跑下面的「您的 XX 時數不夠囉」的 alert，假如時數請超過，會跑喪假防呆的alert以及「您的 XX 時數不夠囉」，這樣會跳兩次alert 18_01_17 碩
                    }else{                            
                        $("#idtext2").html("喪假 剩餘：" + data + "小時");
                        //leftid2 = $("#idtext2").text();
                    }            
                }),error:(function(error){
                    $("#idtext2").html("請重新登入");
                    leftid2 = $("#idtext2").text();
                })
            });        
        }
    });      
});

//刪除假單
$('#delete').click(function(){
    var get = getMSelectedRow($('#user'));
    $('#leaveid2').val(get.PA60004);
    var deletebtn = get.PA60003;
    var pa60002 = get.PA60002;
    var id = get.PA60004;
    var from = get.PA60007;
    var to = get.PA60008;
    var hr = get.PA60011 / 60;
    var cause = get.PA60016;
    var name = get.PA60038;
    $('#removebtn').click(function(){
        $.ajax({
            type:'POST',
            url: 'Tools/leaveuser.ashx?pass=delete&deletebtn=' + deletebtn + '&pa60002=' + pa60002 + '&id=' + id + '&from=' + from + '&to=' + to + '&hr=' + hr + '&cause=' + encodeURI(cause) + '&name=' + encodeURI(name),
            dataType:'json',
            success:(function(data){
                if(data!=null){
                    alert(data.content);
                    location.href = '<%Response.Write(Session["Home"]);%>';}
                else{
                    location.href = '<%Response.Write(Session["Home"]);%>';}
            })
        });
    });
});
        
        
$('#uploadedFiles2').on('change', function () {
    $('#newfile2').html(null);
    $('#alreadyfile2').html(null);
    for (var i = 0; i < this.files.length; i++) {
        if(this.files.length > 1){
            $('#newfile2').append(this.files[i].name + '<br>');
        }
    }

});

$('#update').click(function () {
    $('#update').attr('disabled', true);
    $.isLoading({ text: "假單修改中...." });
    var get = getMSelectedRow($('#user'));
    var user60003 = get.PA60003;
    var id2 = document.getElementById("leaveid2").value;
    var from2 = document.getElementById("leavedate2").value;
    var to2 = document.getElementById("toleavedate2").value;
    var hr2 = document.getElementById("hr2").value;
    var cause2 = document.getElementById("cause2").value;
    var name2 = document.getElementById("jobagent2").value;
    var death = document.getElementById("updeath").value;
    var jobuser = name2.split(" / ");
    var pa39 = get.PA60039;
    var updeath = null;//新增喪假的總分鐘數
    var updeathtime;//將updeath轉小時
    var typetime = death*8;//18_01_17 碩
    if (id2 == '8') {
        if(death == '0'){
            alert('尚未選擇天數');
            return;
        }else {
            $.ajax({
                type:'POST',
                url:'Tools/process.ashx?mode=DeathIgtupdate&type='+death+'&hr='+hr2+'&water='+get.PA60003,
                async:false,
                success:(function(data){
                    if(data == 'igt'){
                        alert('此筆假單的時數 已超過 您所選擇天數別之總時數'+typetime+'小時，煩請更改喪假時數');
                    }  
                    else if(data == 'typeover'){
                        alert('待審中的喪假總時數已達到上限'+death+'日，煩請您聯繫您的主管，將假單進行審核後，再進行申請');
                    }
                    else if(data == 'timeleft over1'){
                        $.ajax({
                            type:'POST',
                            url:'Tools/leftleave.ashx?mode=eightupdate&type='+death+'&water='+get.PA60003,
                            async:false,
                            success:function(data2){
                                alert('此筆假單的時數 已超過 您的剩餘時數'+data2+'小時，煩請更改喪假時數');
                            }
                        });
                    }else if(data == 'timeleft over2'){
                        alert('此筆假單的時數 已超過 您的可請時數，煩請更改申請時數');
                    }
                    else if(data == 'true')
                    {

                    }
                    else
                    {
                        alert('以上皆非');
                    }
                })
            });   
        }
    }
    var fileUpload = $("#uploadedFiles2").get(0);
    var files = fileUpload.files;
    var data1 = new FormData();
    for (var i = 0; i < files.length; i++) {
        data1.append(files[i].name, files[i]);
    }
    var up = uptime(from2, to2);

    var CoDpath = upload2(data1, id2);

    if (id2 == 0 || from2 == "" || to2 == "" || cause2 == "" || name2 == 0) {
        alert('請重新填寫假單，尚有未填寫的欄位，全部皆為必填欄位。');
    } else if (hr2 == 0 || hr2 < 0) {
        alert('請重新填寫起迄時間，起迄時間區間有誤。');
    } 
    else if(leftid2 && leftid2 != "" && leftid2.substring(6,leftid2.length-2) - hr2 < 0)
    {
        var sum = leftid2.substring(6,leftid2.length-2) - hr2 < 0;
        if(leftid2.substring(0,2) != '喪假'){        
            alert('您的' + leftid2.substring(0,2) + '時數不夠囉！');
        }
    }
    else if(CoDpath == "false"){
        alert("您選擇的假別需上傳證明，您是否缺少上傳資料呢？");
    } 
    else if(up == 'from <8'){
        alert('您是8點上班，則8點以前無需請假。');
    }else if(up == 'to >17'){
        alert('您是5點下班，則5點後即無需請假。');
    }else if(up == 'from <9'){
        alert('您是9點上班，則9點以前無需請假。');
    }else if(up == 'to >18'){
        alert('您是6點下班，則6點後即無需請假。');
    }else if(up == 'from <830'){
        alert('您是8點30分上班，則8點30分以前無需請假。');
    }else if(up == 'to >1730'){
        alert('您是5點30分下班，則5點30分後即無需請假。');
    }
        //else if(leftid2 == undefined || parseInt(leftid2.match(/[0-9]+/g)) - hr2 >= 0 || leftid2 =='false')
    else if(leftid2 == undefined || parseFloat(leftid2.match(/[0-9]{0,10}\.[0-9]{0,10}|[0-9]+/g)) - hr2 >= 0 || leftid2 =='false')
    {
        var d = new Date(from2.substr(5,2)+'/'+from2.substr(8,2)+'/'+from2.substr(0,4)+' '+from2.substr(11,5));
        var b = new Date(to2.substr(5,2)+'/'+to2.substr(8,2)+'/'+to2.substr(0,4)+' '+to2.substr(11,5));
        var from_time2 = Date.parse(d);
        var to_time2 = Date.parse(b);

        $.ajax({
            type:'POST',
            url:'Tools/leaveuser.ashx?pass=gender',
            dataType:'json',
        }).success(function(gender){ 
            
            if(gender=='21')
            {
                alert('歸屬未設定正確，請聯繫人資');                      
                $.isLoading( "hide" );
                return;
            }
            //時間區段判斷
            $.ajax({
                type:'POST',
                url:'Tools/leaveuser.ashx?pass=datecheck2&user60003=' + user60003 + '&pa39=' + pa39,
                dataType:'json',
            }).success(function(datecheck2){               
                //var result = this.CheckCondition($.grep(Helper.data, function (i, e) { return (i.Room == $scope.Room.areavalue && i.id != $scope.Current_ID); }), s_time, e_time);//這行
                var result = CheckCondition(datecheck2, from_time2, to_time2);//這行
                if(result == true) 
                {

                    $.each($('input[name="update"]:checked'), function() {

                        var user = $(this).closest('tr').find('td:nth-child(2)').text();
                        var water = $(this).closest('tr').find('td:nth-child(10)').text();

                        $.ajax({
                            async: false,
                            url: 'Tools/leaveuser.ashx?pass=update&gender=' + gender[0].PA51008 + '&user=' + user + '&water=' + water + '&id2=' + id2 + '&from2=' + from2 + '&to2=' + to2 + '&hr2=' + hr2 + '&cause2=' + encodeURIComponent(cause2) + '&name2=' + encodeURI(name2) + '&updeath=' + updeath + '&death=' + death + '&CoDpath=' + CoDpath +'&Hundredtime='+get.PA60047+'&jobuser='+encodeURI(jobuser[0]),
                            type: 'POST',
                            contentType: 'application/json; charset=utf-8'
                        }).success(function (response) {
                            if(response == "False"){
                                alert('男士不可請 產檢、產(娩)、生理假 喔！');
                            }else if(response == '40'){
                                alert('事由字數最高上限為40字喔~');
                            }else if(response == 'dateout'){
                                alert("請假規定必須在當月份完成請假流程，已小於本月月初！");
                            }else if(response == 'weekend'){
                                alert('您是行政人員，六日不用上班，請重新選擇日期');
                            }else if(response == 'National holidays'){
                                alert('您請假的日子裡有國定假日，請重新選擇日期。');
                            }else if(response == "General Manager" && <%= Convert.ToInt32(Session["PAAK200"])%> > 49){
                                alert("您已申請超過連續三天，將交由總經理簽核。");


                                location.href='Home.aspx';
                            }else{

                                location.href='Home.aspx';
                            }
                        }).error(function (data) {

                        });
                    });
}
else
{

    alert('您選擇的時段區間已有假單');
}
                
            });
        });

}


});
function upload2(data, id2) {
    var path;
    $.ajax({
        type: "post",
        url: "Tools/leaveuser.ashx?pass=upload&id="+id2,
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
//職代
$.ajax({
    type: 'POST',
    url: 'Tools/leaveuser.ashx?pass=jobagent',
    dataType: 'json',
    contentType: 'application/json; charset=utf-8'
}).then(function (data) {
    $('#jobagent2').empty().append($('<option></option>').val('0').text('請選擇'));
    data: $.map(data, function (obj) {
        $('#jobagent2').append($('<option></option>').val(obj.name).text(obj.name));
    });

});


    </script>


</asp:Content>
