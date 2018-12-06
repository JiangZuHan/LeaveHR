<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/請假主版.Master" CodeBehind="Home_produceline.aspx.cs" Inherits="全傳請假系統.Home_produceline" %>


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

                                <div class="input-group col-xs-12 col-sm-1 col-lg-1 col-md-1" style="margin-left: 5px; display: inline;" id="Class_time">
                                    <label class="control-label" id="Cls_range"></label>
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
                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">請選擇歸屬</label>
                                    </div>
                                    <div class="input-group col-xs-10 col-sm-8 col-lg-8">
                                        <select id="line" class="form-control" style="width: 170px; height: 35px"></select><div style="color: red; font-weight: bold">選擇時請注意下方主管的變動</div>
                                    </div>
                                </div>
                                <div class="input-group col-md-12" id="Alternative" style="margin-top: 10px; display: none">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">代KEY請假人員名單</label>
                                    </div>
                                    <div class="input-group col-xs-10 col-sm-8 col-lg-8">
                                        <select id="Alternative_Hugh" class="form-control" style="width: 300px; height: 35px"></select>
                                        <div style="color: red; font-weight: bold">注意:選擇後所有申請資訊將為代KEY者資料</div>
                                    </div>


                                </div>
                                <hr />
                                <div class="input-group col-xs-12 col-sm-12 col-lg-12 text-center">
                                    ↓選擇簽核主管↓
                                </div>
                                <hr />

                                <div class="input-group col-md-12" style="margin-top: 10px">
                                    <div id="leadertitle">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">組長</label>
                                        </div>
                                        <div class="input-group col-xs-4 col-sm-4 col-lg-4 col-md-4">
                                            <select id="leader" class="id2 form-control" style="width: 170px;"></select>
                                        </div>
                                    </div>
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
        
        $('#insertmodal').mousedown(function(){
            var time1 = $('#leavedate').val() || '';
            var time2 = $('#toleavedate').val() || '';
            var Alternative = $('#Alternative_Hugh').val() || '';

            if (time1 != "" && time2 != "") {

                var url = 'Tools/datetime_produceline.ashx?mode=time&time1=' + time1 + '&time2=' + time2;

                url = Alternative != '' ? url + '&Alternative=' + Alternative : url;

                $.ajax({
                    type: 'POST',
                    url: url,
                    async:false,
                    success: function (response) {
                        $('#hr').val(response);
                    }
                });

                //判斷總經理開啟
                var hr = $('#hr').val() *1 ;
                if (hr > 24 || <%= Convert.ToInt32(Session["PAAK200"])%> < 39) {
                    $('#bossone').css('display', 'block')
                } else {
                    $('#bossone').css('display', 'none')
                }

                bos_display(hr)
                //jungle
                Get_CurrentClassTime();
            }
        });
        $('#uploadedFiles').on('change', function () {
            $('#newfile').html(null);
            $('#alreadyfile').html(null);
            for (var i = 0; i < this.files.length; i++) {
                if(this.files.length > 1){
                    $('#newfile').append(this.files[i].name + '<br>');
                }
            }

        });
        $('#user').on('click-row.bs.table', function (e, row, $element) {
            $('.warning').removeClass('warning');
            $($element).addClass('warning');

            var get = getMSelectedRow($('#user'));
            $.ajax({
                type:'POST',
                url:'Tools/leaveuser_produceline.ashx?pass=tableclick&PA60039='+get.PA60039,
                async: false,
                success:(function(data){
                    if(data == 'true'){
                        $('#delete').attr('disabled', true);
                    }else{
                        $('#delete').attr('disabled', false);
                    }
                })
            });
        });
        $('#leaveid, #Alternative_Hugh').change(function () {
            var Alternative = $('#Alternative_Hugh').val() || '';
            id = $('#leaveid').find(':selected').attr('data-id');
            if(Alternative != ''){
                //使用請假人的資訊去抓取資料
                if (id == "eight") {
                    Iseight(id, Alternative);
                }
                else{
                    Noteight(id,Alternative);
                }
            }else
            {
                //使用登入者資訊抓取資料
                if (id == "eight") {
                    Iseight(id);
                }
                else{
                    Noteight(id);
                }
            }
            // 把下拉先清除後 再塞入不同的歸屬代號
            $('#line').empty();

            line_value(Alternative);
            //用代KEY人更新主管下拉名字
            $.ajax({
                async: false,
                url: 'Tools/leaveuser_produceline.ashx?pass=line_select&ProgNo='+$('#line').val()+'&Alternative='+Alternative,
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8'
            }).then(function (respon) {
       
                $('#leader').empty();
                $('#chief').empty();
                $('#level2').empty();
                $('#level1').empty();

                //組長
                if(respon[0].LUSERID != ''){
                    $('#leader').append($('<option value="'+respon[0].LUSERID.split('/')[0]+'"></option>').text(respon[0].LUSERID.split('/')[1]));
                }

                //課長
                if(respon[0].SUSERID != ''){
                    $('#chief').append($('<option value="'+respon[0].SUSERID.split('/')[0]+'"></option>').text(respon[0].SUSERID.split('/')[1]));
                }

                //單位主管
                if(respon[0].DUSERID != ''){
                    $('#level2').append($('<option value="'+respon[0].DUSERID.split('/')[0]+'"></option>').text(respon[0].DUSERID.split('/')[1]));
                }

                //部門主管
                if(respon[0].MUSERID != ''){
                    $('#level1').append($('<option value="'+respon[0].MUSERID.split('/')[0]+'"></option>').text(respon[0].MUSERID.split('/')[1]));
                }
                
            });
            display_();
            jobagent(Alternative);
        });
        //歸屬下拉change事件
        $('#line').change(function(){
            var ProgNo = $('#line').val();
            var Alternative = $('#Alternative_Hugh').val() || '';

            $.ajax({
                async: false,
                url: 'Tools/leaveuser_produceline.ashx?pass=line_select&ProgNo='+ProgNo+'&Alternative='+Alternative,
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8'
            }).then(function (response) {
       
                $('#leader').empty();
                $('#chief').empty();
                $('#level2').empty();
                $('#level1').empty();

                //組長
                if(response[0].LUSERID != ''){
                    $('#leader').append($('<option value="'+response[0].LUSERID.split('/')[0]+'"></option>').text(response[0].LUSERID.split('/')[1]));
                }

                //課長
                if(response[0].SUSERID != ''){
                    $('#chief').append($('<option value="'+response[0].SUSERID.split('/')[0]+'"></option>').text(response[0].SUSERID.split('/')[1]));
                }

                //單位主管
                if(response[0].DUSERID != ''){
                    $('#level2').append($('<option value="'+response[0].DUSERID.split('/')[0]+'"></option>').text(response[0].DUSERID.split('/')[1]));
                }

                //部門主管
                if(response[0].MUSERID != ''){
                    $('#level1').append($('<option value="'+response[0].MUSERID.split('/')[0]+'"></option>').text(response[0].MUSERID.split('/')[1]));
                }
                display_();
            });
        })
        //$('#btn').click(function(){
        
        //    $.ajax({
        //        type:'POST',
        //        url:'Tools/leaveuser_produceline.ashx?pass=CheckSession',
        //        async:false,
        //        cache:false,
        //        success:(function(data){

        //        })
        //    });             
        
        //})
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
            var ProgNo = $('#line').val();

            var Alternative = $('#Alternative_Hugh').val() || '';

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
                        url:'Tools/process_produceline.ashx?mode=DeathIgt&type='+death+'&hr='+hr+'&from='+from+"&Hundred="+($('#Hundred').val()||null),
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
                                    url:'Tools/leftleave_produceline.ashx?mode=eight&type='+death,
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
                           
                                insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser[0],ProgNo,Alternative);
                            }else{
                                alert('以上皆非');
                            }
                        })
                    });          
                }
            }
            else
            {
            
                insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser[0],ProgNo,Alternative);
            }

        });
        $('#close').click(function() {
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
            $('#Alternative_Hugh').val("");
    
            $('#indeathdiv').attr("style", "display: none");
            if (<%= Convert.ToInt32(Session["PAAK200"])%> > 49) {
                $('#bossone').attr("style", "display: none");
            }
        });

        //刪除假單
        $('#delete').click(function(){
            var get = getMSelectedRow($('#user'));
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
                    url: 'Tools/leaveuser_produceline.ashx?pass=delete&deletebtn=' + deletebtn + '&pa60002=' + pa60002 + '&id=' + id + '&from=' + from + '&to=' + to + '&hr=' + hr + '&cause=' + encodeURI(cause) + '&name=' + encodeURI(name),
                    dataType:'json',
                    success:(function(data){
                        if(data!=null)
                            alert(data.content);
                        else
                            location.href = '<%Response.Write(Session["Home"]);%>';
                    })
                });
            });
        });
        
        

            if (<%= Convert.ToInt32(Session["PAAK200"])%> < 49 && <%= Convert.ToInt32(Session["PAAK200"])%> != 20) {
            document.getElementById("bossone").style.display = "black";
        } else {
            document.getElementById("bossone").style.display = "none";
        }
        if ("<%= Session["PADF"]%>" == "留職停薪") {
            $('#btn').attr('disabled', 'disabled');
        }
        var leftid,leftid2;
        var Hundred = 1;//判斷是否還需要填寫訃聞時間，0→要，1→不需要
        var Hundredtime = '';
       
        $('#Hundred').datetimepicker({
            format: 'yyyy-mm-dd',
            language: 'zh-TW',
            maxView: 3,
            minView: 2,
            autoclose: true,
        });
        $('#leavedate, #toleavedate').datetimepicker({
            format: 'yyyy-mm-dd hh:ii',
            //use24hours: true,
            language: 'zh-TW',
            autoclose: true,
            //daysOfWeekDisabled: [0, 6],
            //enabledDates:_Holiday.NeedWorkHoliday,
            //maxView: 3,
            //minView: 2,
            ////minView: 'month',
            minuteStep: 30
        });
        $('#leavedate').datetimepicker().on('changeDate', function (ev) {
            $('#toleavedate').datetimepicker('setStartDate', ev.date);

            Get_CurrentClassTime();

        });
        $('#toleavedate').datetimepicker().on('changeDate', function (ev) {

            Get_CurrentClassTime();

        });
        function getMSelectedRow(xxx) {
            var index = xxx.find('tr.warning').data('index');
            return xxx.bootstrapTable('getData')[index];
        }
        function Iseight(id,Alternative){
            var typeid;
            var a = $('#indeath').val();
            var data_deathtwice = 'Tools/process_produceline.ashx?mode=deathtwice';

            var data_eight_type='Tools/leftleave_produceline.ashx?mode=' + id;
            var data_eight_left ='Tools/leftleave_produceline.ashx?mode=' + id+'&type='+a;

            if(Alternative != undefined){
                data_deathtwice = data_deathtwice + '&Alternative_user='+Alternative;
                data_eight_type = data_eight_type + '&Alternative_user='+Alternative;
                data_eight_left = data_eight_left + '&Alternative_user='+Alternative;

            }
            //喪假剩餘時數   


            Hundred = 0;
            $('#indeathdiv').attr('style','display:block');
            //判斷資料庫裡有無喪假之剩餘時數
            $.ajax({
                type:'POST',
                url:data_deathtwice,
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

                
            if(a == '0'){//2018_01_18 碩，天數下拉還沒change的時候，就等change才執行
                $('#indeath').change(function(){                         
                    typeid = $('#indeath option:selected').val();                   
                    $.ajax({
                        type:'POST',
                        url:data_eight_type+'&type='+typeid,
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
                    url:data_eight_left,
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

        function Noteight(id,Alternative){
            //除了喪假
            var data = 'Tools/leftleave_produceline.ashx?mode=' + id + '&insert=false';
            if(Alternative != undefined){
                data = data + '&Alternative_user='+Alternative;

            }

            $('#indeathdiv').hide(500).attr('style','display:none');

            //特休
            $.ajax({
                type:'POST',
                url:data,
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
        }
        function Get_CurrentClassTime(){
            $leavedate=$('#leavedate');
            $toleavedate=$('#toleavedate');
            var Alternative = $('#Alternative_Hugh').val() || '';
            if($leavedate.val()!=''&&$toleavedate.val()!=''){
                $.ajax({
                    type:'GET',
                    url:'Tools/leftleave_produceline.ashx?mode=Working&user='+Alternative,
                    async:false,
                    dataType:'json',
                    data:{
                        leavedate:$leavedate.val(),
                        toleavedate:$toleavedate.val()
                    },
                    success:function(result){

                        $('#Class_time>label').empty();

                        if($.isEmptyObject(result))
                            return;

                        result.forEach(function(i,idx){

                            if(idx!=0)
                                $('#Class_time>label').append("<br>");

                            $('#Class_time>label').append(i.Range+"<br>"+i.ClsName);
                        })                        
                    }
                })
            }
        }


        function insert(id,from,to,hr,cause,name,death,Hundredtime,jobuser,ProgNo,Alternative) {
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
            //var up = uptime(from, to);
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
            else if(leftid == "" || parseFloat(leftid.match(/[0-9]{0,10}\.[0-9]{0,10}|[0-9]+/g)) - hr >= 0 || leftid=='false') {
                $('#insert').attr('disabled', true);


                var d = new Date(from.substr(5,2)+'/'+from.substr(8,2)+'/'+from.substr(0,4)+' '+from.substr(11,5));
                var b = new Date(to.substr(5,2)+'/'+to.substr(8,2)+'/'+to.substr(0,4)+' '+to.substr(11,5));
                var from_time = Date.parse(d);
                var to_time = Date.parse(b);

                $.ajax({
                    type:'POST',
                    url:'Tools/leaveuser_produceline.ashx?pass=gender',
                    dataType:'json',
                }).success(function(gender){
                    if(gender=='21')
                    {
                        alert('歸屬未設定正確，請聯繫人資');
                        return;
                    }
            
                    //時間區段判斷
                    $.ajax({
                        type:'POST',
                        url:'Tools/leaveuser_produceline.ashx?pass=datecheck&Alternative_user='+Alternative,
                        dataType:'json',
                    }).success(function(datecheck){
                        
                        
                        //var result = this.CheckCondition($.grep(Helper.data, function (i, e) { return (i.Room == $scope.Room.areavalue && i.id != $scope.Current_ID); }), s_time, e_time);//這行
                        var result = CheckCondition(datecheck, from_time, to_time);//這行
                        if(result == true)
                        {
                            
                            $.ajax({
                                async: false,                   
                                url: 'Tools/leaveuser_produceline.ashx?pass=insert&gender=' + gender[0].PA51008 + '&id=' + id + '&from=' + from + '&to=' + to + '&hr=' + hr + '&cause=' + encodeURIComponent(cause) + '&name=' + encodeURI(name) +'&death='+death+'&CoDpath='+CoDpath+'&Hundredtime='+Hundredtime+'&jobuser='+jobuser+'&ProgNo='+ProgNo+'&Alternative='+Alternative,
                                type: 'POST',                               
                                contentType: 'application/json; charset=utf-8'
                            }).success(function (response) {
                                if(response == "False"){
                                    alert('男士不可請 產檢、產(娩)、生理假 喔！');
                                }else if(response == '40'){
                                    alert('事由字數最高上限為40字喔~');
                                }else if(response == 'dateout'){
                                    alert("請假規定必須在當月份完成請假流程，已小於本月月初！");
                                }else if(response == "images not"){
                                    alert("您選擇的假別需上傳證明，您是否缺少上傳資料呢？");
                                }else if(response == "not jpg"){
                                    alert("上傳證明資料必須為圖片檔(.png、.jpg、.gif)、PDF檔(.pdf)。");
                                }else if(response == "班別錯誤"){
                                    alert("您好！請假產生錯誤。原因：請假範圍中有2種以上班別，麻煩請分開請假！謝謝。")
                                }else if(response == "無班表"){
                                    alert("您好！請假產生錯誤。原因：請假區間是沒有班表的，麻煩請等待出班表後再申請假單！謝謝。")
                                }else if(response == "生理超過次數"){
                                    alert("您已經申請過生理假，此假別一個月只能申請一次。");
                                }else if(response == "生理假只能請一天"){
                                    alert("您好！請假產生錯誤。原因：請生理假只能單月請一天，您請假時數大於一天，請重新選擇時間！謝謝。");
                                }else{

                                    location.href='<%Response.Write(Session["Home"]);%>';
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

}
function tenhr(from){
    var ten;
    $.ajax({
        type:'POST',
        async:false,
        url:'Tools/leftleave_produceline.ashx?mode=ten'+'&from='+from,
        contentType: 'application/json; charset=utf-8'
        //dataType:'json',
    }).success(function(hr){
        ten = JSON.parse(hr);
    });
    return ten;
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
function display_(){

    //顯示課長可使用相關畫面
    if (<%= Convert.ToInt32(Session["PAAK200"])%> <= 58 && <%= Convert.ToInt32(Session["PAAK200"])%> >= 50 )
    {
        //登入為課長or副理
        //待審按鈕開啟
        if ($('#check')){
            $('#check').css('display','block')
        }
        if($('#check2')){
            $('#check2').css('display','block')
        }
            
    } 

    //等文中籍職更改後即可修回此段 48~38
    if (<%= Convert.ToInt32(Session["PAAK200"])%> <= 48 && <%= Convert.ToInt32(Session["PAAK200"])%> >= 35 )
    {
        //登入為課長or副理
        if ($('#check')){
            $('#check').css('display','block')
        }
        if($('#check2')){
            $('#check2').css('display','block')
        }

        //課長or副裡不用看到自己以下的簽核
        document.getElementById("level2title").style.display="none";  //隱藏單位主管(二階主管)
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        $('#leadertitle').css('display','none');

        
        //抓部門主管的值
        var level1 = $('#level1').text();
        if(level1 == "")
        {
            //沒有部門主管，就總經理出現
            document.getElementById("level1title").style.display="none";  //隱藏部門主管(一階主管)
            document.getElementById("bossone").style.display="block";  //總經理開啟

        }else{
            document.getElementById("level1title").style.display="block";  //開啟部門主管(一階主管)
            document.getElementById("bossone").style.display="none";  //總經理隱藏
        }
            
            
    } 
        //等文中籍職更改後即可修回此段 39~10
    else if(<%= Convert.ToInt32(Session["PAAK200"])%> < 35 && <%= Convert.ToInt32(Session["PAAK200"])%> >= 10 )
    {
        //登入為最高級主管
        if(<%= Convert.ToInt32(Session["PAAK200"])%> != 20){
            if ($('#check')){
                $('#check').css('display','block')
            }
            if($('#check2')){
                $('#check2').css('display','block')
            }
        }else{
            if ($('#check')){
                $('#check').css('display','none')
            }
            if($('#check2')){
                $('#check2').css('display','none')
            }
        }

        //最高級只要看到總經理簽核
        $('#leadertitle').css('display','none');
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        document.getElementById("level1title").style.display="none";  //隱藏部門主管(最高級主管)
        document.getElementById("bossone").style.display="block";  //總經理開啟
    }
    else if(<%= Convert.ToInt32(Session["PAAK200"])%> == 1)
    {
        //登入為總經理
        if ($('#check')){
            $('#check').css('display','block')
        }

        document.getElementById("leadertitle").style.display="none"; //隱藏組長
        document.getElementById("chieftitle").style.display="none"; //隱藏課長
        document.getElementById("level2title").style.display="none";
        document.getElementById("level1title").style.display="none";
        document.getElementById("bossone").style.display="none";

    }
    else{

        var level2 = $('#level2').text(); //取單位主管的文字
        var level1 = $('#level1').text(); //取部門主管的文字
        var chief = $('#chief').text(); //取課長的文字
        var leader = $('#leader').val() || '';

        //單位主管
        if(level2 == ""){
            document.getElementById("level2title").style.display="none";
        }else{
            $('#level2title').css('display','block');
        }

        //部門主管
        if(level1 == ""){
            document.getElementById("level1title").style.display="none";
        }else{
            $('#level1title').css('display','block');
        }

        //課長
        if(chief == ""){
            document.getElementById("chieftitle").style.display="none";
        }else{
            $('#chieftitle').css('display','block');
        }
        //組長
        if(leader == "" || leader == '<% Response.Write(Session["username"]);%>'){
            $('#leadertitle').css('display','none');
        }else{
            $('#leadertitle').css('display','block');
        }
    }
}
function All_display_(type_text,type_){
    if(type_text != ''){
        $('#'+type_ +'title').css('display','block');
    }else{
        $('#'+type_ +'title').css('display','none');
    }
}


function bos_display(hr){
    var level2 = $('#level2').text() || ''; //取單位主管的文字
    var level1 = $('#level1').text() || ''; //取部門主管的文字
    var chief = $('#chief').text() || ''; //取課長的文字
    var leader = $('#leader').text() || '';  //取組長的文字

    $('#leadertitle').css('display','none');
    $('#chieftitle').css('display','none');
    $('#level2title').css('display','none');
    $('#level1title').css('display','none');

    if(hr*1 <=8){
        All_display_(leader,'leader'); //組長無論請多久 都需要簽核 (除了沒組長之外)
        //判斷顯示主管
        if(chief != ''){
            //課長有值 顯示課長即可
            All_display_(chief,'chief');
        }
        else if(level2 != ''){
            //無課長  副理有值 顯示副理
            All_display_(level2,'level2');
        }
        else if(level1 != ''){
            //無課長  副理有值 顯示副理
            All_display_(level1,'level1');
        }
    }
    else if(hr*1 >8 && hr*1 <=16){
        All_display_(leader,'leader');//組長無論請多久 都需要簽核 (除了沒組長之外)
        All_display_(chief,'chief');//請假一天以下時 課長若不是空白 即要顯示
        All_display_(level2,'level2');//1天以上 2天以下 若單位主管不是空白 即要顯示

        if(level2==''&&chief==''){
            All_display_(level1,'level1');
        }
    }
    else if(hr*1 > 16){
        //組長無論請多久 都需要簽核 (除了沒組長之外)
        All_display_(leader,'leader');

        //請假一天以下時 課長若不是空白 即要顯示
        All_display_(chief,'chief');

        //1天以上 2天以下 若單位主管不是空白 即要顯示
        All_display_(level2,'level2');

        //2天以上 3天以下 若部門主管不是空白 即要顯示
        All_display_(level1,'level1');
    }

}
function jobagent(Alternative){
    //職代
    var url = 'Tools/leaveuser_produceline.ashx?pass=jobagent';
    if(Alternative != null){
        url = url + '&Alternative='+Alternative;
    }
    $.ajax({
        type: 'POST',
        url: url,
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (data) {
        $('#jobagent').empty().append($('<option></option>').val('0').text('請選擇'));
        data: $.map(data, function (obj) {
            $('#jobagent').append($('<option></option>').val(obj.name).text(obj.name));
        });

    });
}
function level2(){
    //單位主管
    $.ajax({
        async: false,
        url: 'Tools/leaveuser_produceline.ashx?pass=level2',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#level2').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });
}
function level1 (){
    //部門主管
    $.ajax({
        async: false,
        url: 'Tools/leaveuser_produceline.ashx?pass=level1',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#level1').append($('<option></option>').text(obj.CNname));
            return obj;
        })

    });
}
function chief(){
    //課長
    $.ajax({
        async: false,
        url: 'Tools/leaveuser_produceline.ashx?pass=chief',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#chief').append($('<option></option>').text(obj.CNname));
            return obj;
        })
    });
}
function leader(){
    //組長
    $.ajax({
        async: false,
        url: 'Tools/leaveuser_produceline.ashx?pass=leader',
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {

        data: $.map(response, function (obj) {
            $('#leader').append($('<option></option>').text(obj.CNname));
            return obj;
        })
    });
}
function line_value(Alternative){

    var url = 'Tools/leaveuser_produceline.ashx?pass=line';
    url = Alternative == null ? url : url+'&Alternative='+Alternative;
    //選擇歸屬
    $.ajax({
        async: false,
        url: url,
        type: 'POST',
        //dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {
        var list = response.split(',');
        var arr = list[0].split('/');
        var a2 = list[1];
        for(var i = 0 ;i<arr.length-1;i++){
            if(arr[i] == a2){
                $('#line').append($('<option value="'+arr[i]+'" selected="selected"></option>').text(arr[i]));
            }else{
                $('#line').append($('<option value="'+arr[i]+'" ></option>').text(arr[i]));
            }
        }
    });
}
function upload(data, num) {
    var path;
    $.ajax({
        type: "post",
        url: "Tools/leaveuser_produceline.ashx?pass=upload&id="+num,
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
function Alternative_select_list(){
    $.ajax({
        async: false,
        url: 'Tools/leaveuser_produceline.ashx?pass=Alternative_List',
        type: 'POST',
        //dataType: 'json',
        contentType: 'application/json; charset=utf-8'
    }).then(function (response) {
        var arr =JSON.parse(response.split(';')[1]);
        $('#Alternative').css('display',response.split(';')[0]);
        if(response.split(';')[0] == 'block'){
            $('#Alternative_Hugh').select2({multiple: true,maximumSelectionLength:1})
            for(var i = 0 ;i<arr.length;i++){
                $('#Alternative_Hugh').append($('<option value = "' + arr[i].username + '"></option>').text(arr[i].dep));
            }
        }
    });
}
function Get_user_table(){
    //審核中(個人)
    $.ajax({
        type: "POST",
        url: "Tools/leaveuser_produceline.ashx?pass=user",
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
                        {field:'PA60047',title:'訃聞日期',class:'hiddencol'},
                        {field:'PA60996',title:'KEY單人',class:'hiddencol'}
                ]
            });
        }
    });
}
function rowStyle(row, index) {
    if (row.PA60039 == 5) {
        return {
            classes: 'danger'
        };
    }
    return {};
}

        function process(water){
            var process1,process2,process3,process4;
            processremove();//每次進來先重置
            //alert(water);
            $.ajax({//判斷有無審核中的假單
                type:'POST',
                url:'Tools/process_produceline.ashx?mode=aprocess&water='+water,
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
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
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
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');
                                
                                $('#process2').html('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');
                                $('#process3').html('最高級主管 通過<br>'+data[0].PA60999.replace('T',' '));
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');

                                $('#span3').attr('style','font-size: x-large;display:block');

                                $('#process44').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 5)
                            {
                                $('#process1').html('假單退件');
                                $('#process1').attr('style','color:red');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').html('二階主管 退件');
                                $('#process2').attr('style','color:red');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span2').attr('style','font-size: x-large;display:block');
                                
                                $('#process3').html('最高級主管 退件');
                                $('#process3').attr('style','color:red');
                                $('#process33').attr('style','display:block');

                                $('#span3').attr('style','font-size: x-large;display:block');
                                $('#span3').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#process44').attr('style','display:block');
                                $('#process4').html('總經理 退件<br>'+data[0].PA60999.replace('T',' '));
                                $('#process4').attr('style','color:red');
                                
                                //寫入文中、將pa60041改成1(代表User已看過)
                                if(data[0].PA60041 != 1){
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process_produceline.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }
                            }
                            else//data[0].PA60039 == 0
                            {
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');
                                
                                $('#process2').html('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');



                                if(data[0].PA60011 > 1440 )
                                {
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 通過');
                                    $('#process3').attr('style','color:green');
                                    $('#process33').attr('style','display:block');

                                    $('#process4').html('總經理 通過<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process4').attr('style','color:green');

                                }else{
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 通過<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process3').attr('style','color:green');
                                    $('#process33').attr('style','display:block');
                                }  
                                if(data[0].PA60041 != 1){
                                    //寫入文中、將pa60043改成1
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process_produceline.ashx?mode=update60&water=' + water,
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
                                $('#process1').html('申請成功 <br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process33').attr('style','display:block');
                            }
                            else if(data[0].PA60039 == 2||data[0].PA60039 == 3)
                            {
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');
                                $('#process2').html('二階主管 通過<br>'+data[0].PA60999.replace('T',' '));
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');

                                $('#process33').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 4)
                            {
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');
                                
                                $('#process2').html('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                $('#span2').attr('style','font-size: x-large;display:block');
                                $('#process3').html('最高級主管 通過<br>'+data[0].PA60999.replace('T',' '));
                                $('#process3').attr('style','color:green');
                                $('#process33').attr('style','display:block');

                            }
                            else if(data[0].PA60039 == 5)
                            {
                                $('#process1').html('假單退件');
                                $('#process1').attr('style','color:red');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').html('二階主管 退件');
                                $('#process2').attr('style','color:red');
                                $('#process22').attr('style','display:block');

                                if(data[0].PA60011 > 1440 )
                                {
                                    $('#span2').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 退件');
                                    $('#process3').attr('style','color:red');
                                    $('#process33').attr('style','display:block');

                                    $('#span3').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                    $('#process4').html('總經理 退件<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process4').attr('style','color:red');

                                }else{
                                    $('#span2').attr('class','glyphicon glyphicon-arrow-left');//箭頭轉向
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 退件<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process3').attr('style','color:red');
                                    $('#process33').attr('style','display:block');
                                }
                                if (data[0].PA60041 != 1){
                                    //寫入文中、將pa60041改成1(代表User已看過)
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process_produceline.ashx?mode=update60&water=' + water,
                                        contentType:'application/json; charset=utf-8',
                                        success:(function(data2){
                                        })
                                    });
                                }
                            }
                            else//data[0].PA60039 == 0
                            {
                                $('#process1').html('申請成功<br>'+data[0].PA60998.replace('T',' '));
                                $('#process1').attr('style','color:green');
                                $('#process11').attr('style','display:block');

                                $('#span1').attr('style','font-size: x-large;display:block');

                                $('#process2').html('二階主管 通過');
                                $('#process2').attr('style','color:green');
                                $('#process22').attr('style','display:block');

                                if(data[0].PA60011 > 1440 )
                                {
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 通過');
                                    $('#process3').attr('style','color:green');
                                    $('#process33').attr('style','display:block');

                                    $('#process4').html('總經理 通過<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process4').attr('style','color:green');

                                }else{
                                    $('#span2').attr('style','font-size: x-large;display:block');
                                    $('#process3').html('最高級主管 通過<br>'+data[0].PA60999.replace('T',' '));
                                    $('#process3').attr('style','color:green');
                                    $('#process33').attr('style','display:block');
                                }
                                if(data[0].PA60041 != 1){
                                    //寫入文中、將pa60043改成1
                                    $.ajax({
                                        type:'POST',
                                        url:'Tools/process_produceline.ashx?mode=update60&water=' + water,
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


$(document).ready(function () {
            
    jobagent();  //職務代理人
    leader();  //組長
    chief();  //課長主管
    level2();  //單位主管
    level1();  //部門主管
    line_value(); //預設的歸屬
    display_();  //主管顯示判斷
    Alternative_select_list();  //代KEY的人員名單  (被代KEY人員)
    Get_user_table();  //抓取個人審核中的table資料

    //nav 上的待審核按鈕是否可見
    if( <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
    {
        if(document.getElementById("check"))
            document.getElementById("check").style.display="block";  
        if(document.getElementById("check2"))
            document.getElementById("check2").style.display="block";  
    }
});

    </script>


</asp:Content>
