<%@ Page Title="" Language="C#" MasterPageFile="~/請假主版.Master" AutoEventWireup="true" CodeBehind="AllecDoor.aspx.cs" Inherits="全傳請假系統.AllecDoor" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="CSS/bootstrap-datetimepicker.min.css" rel="stylesheet" />

    <script src="js/bootstrap-datetimepicker.min.js"></script>
    <script src="js/bootstrap-datetimepicker.zh-TW.js"></script>

    <script>

        $(document).ready(function () {

            //nav 上的待審核按鈕是否可見
        if(  <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
            {
                if(document.getElementById("check"))
                    document.getElementById("check").style.display="block";  
                if(document.getElementById("check2"))
                    document.getElementById("check2").style.display="block";  
            }


  <%--          if (<%= Convert.ToInt32(Session["PAAK200"])%> < 49 && "<%= Session["PAAK200"] %>" != "20") {
                document.getElementById("check").style.display="block";
            } --%>
            var xcoddep = "<%= Session["a1"] %>";
            var xPAAK200 = "<%=Session["PAAK200"] %>";
            var userid="<%=Session["UserName"] %>";
            var zfbNO = "<%=Session["zfbNO"] %>";

            $('#Hidden1').text(xcoddep + ";" + xPAAK200 + ";" + userid + ";" + zfbNO);
            if (xcoddep == "003") {
                $('#dcoddep').show();
            }
            else {
                $('#dcoddep').hide("fast");
            }

            var d = new Date();
            var today = d.getFullYear().toString() + '-' + ('0' + (d.getMonth() + 1)).slice(-2) + '-' + ('0' + d.getDate()).slice(-2) ;

            $('#start').val(today);
            $('#end').val(today);

            $('#checklist').bootstrapTable({
                cache: false,
                locales: "zh-CN",
                method: 'post',
                pagination: true,
                search: true,
                advancedSearch: true,
                idTable: 'advancedTable',
                pageList: "[10, 25, 50, 100, ALL]",
                //sortName: 'AddTime',
                sortOrder: 'desc',
                toolbar: "#toolbar",
                contentType: 'application/x-www-form-urlencoded',
                //                url: '../Tools/NEShow.ashx?mode=NEShowM',
                columns: [[
                    { field: 'l01', title: '刷卡時間', width: '100px', halign: 'center', valign: 'middle' },
                    { field: 'l15', title: '部門', width: '50px', halign: 'center', valign: 'middle' },
                    { field: 'xPA51020', title: '班別', width: '20px', halign: 'center', valign: 'middle' },
                    { field: 'CPA51020', title: '班別', width: '100px', halign: 'center', valign: 'middle' },
                    { field: 'P01', title: '卡號', width: '50px', halign: 'center', valign: 'middle' },
                    { field: 'l07', title: '人員', width: '70px', halign: 'center', valign: 'middle' },
                    {
                        field: 'xMinute', title: '請假小時', width: '20px', halign: 'center', valign: 'middle',visible:false,
                        formatter: function (val, row) {
                            if (val != "--")
                            {
                                return "<span style='color:red;font-weight:bold;'>" + val + "</span>";
                            }
                            else
                            {
                                return val;
                            }
                        }
                    },
                    {
                        field: 'YN', title: '是否要請假', width: '20px', halign: 'center', valign: 'middle',visible:false,
                        formatter: function (val, row) {
                            if (val == "Y") {
                                return "<span style='color:red;font-weight:bold;'>" + val + "</span>";
                            }
                            else {
                                return val;
                            }
                        }
                    }
                ]],
                rowStyle: function rowStyle(value, row, index) {
                    return {
                        css: { "height": "50px", "word-break": "break-all" }
                    };
                },
                onLoadSuccess: function (data1) {
                    $('#xsearch').attr('disabled', false);
                    $.isLoading("hide")
                }
            });

            $('#start, #end').datetimepicker({
                format: 'yyyy-mm-dd',
                use24hours: true,
                language: 'zh-TW',
                //                getDefaultFormat: 'standard',
                autoclose: true,
                minView: 'month'
                //                minuteStep: 30
            });
            $('#start').datetimepicker().on('changeDate', function (ev) {
                //OrderReturnDate enable after OrderPickDate
                $('#end').datetimepicker('setStartDate', ev.date);
            });

            $.ajax({
                async: false,
                url: '../Tools/HR.ashx?mode=Showdep&xShow=' + xcoddep + '&userid=' + userid + '&zfbNO=' + zfbNO,
                type: 'POST',
                dataType: 'json',
                contentType: 'application/json; charset=utf-8'
            }).then(function (response) {
                $("#coddep").select2({
                    width: '100%',
                    placeholder: "請選擇",
                    allowClear: true,
                    data: $.map(response, function (obj) {
                        obj.id = obj.id || obj.PA11002; // replace pk with your identifier
                        obj.text = obj.text || obj.PA11003; // replace pk with your identifier
                        return obj;
                    })
                });
                //                alert(response);
            });

            if (parseInt(xPAAK200) <= 50) {
                $('#dcoddep').show();
                $('#coddep').val(xPAAK200).trigger("change");
            };
        });

        function search() {
            
            $('#xsearch').attr('disabled', true);
            $.isLoading({ text: "下載中...." });
            $('#checklist').bootstrapTable('refreshOptions', {
                cache: false,
                contentType: 'application/x-www-form-urlencoded',
                url: 'Tools/HR.ashx?mode=checklist',
                //                toolbar: '.toolbar',
                queryParams: queryParams,
            });
        }

        function queryParams() {
            var start = $('#start').val();
            var end = $('#end').val();
            var search = $('#searchtxt').val();
            var coddep = $('#coddep').val();
            if (coddep == 'ALL')
            {
                coddep = "";
                for (var i = 0; i < $("#coddep option").size() ; i++) {
                    if (i > 1) {
                        coddep += $("#coddep option").get(i).value + ";";
                    };
                };
                coddep = coddep.substr(0, coddep.length - 1);
            }
            var params = { 'start': start, 'end': end, 'search': '', 'coddep': coddep, 'PAKK': $('#Hidden1').text() };
            return params;
        }
    </script>
    <style type="text/css">
        .bootstrap-table {
            width: 90%;
            margin-left: auto;
            margin-right: auto;
        }

        .select2-container .select2-selection--multiple {
            box-sizing: border-box;
            cursor: pointer;
            display: block;
            min-height: 132px;
            user-select: none;
            -webkit-user-select: none;
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

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container" id="ontopDiv">
        <ul class="nav nav-tabs">
            <li role="presentation"><a href="<%Response.Write(Session["Home"]);%>">假單申請</a></li>
            <li role="presentation" class="active"><a href="AllecDoor.aspx">打卡查詢</a></li>
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
    <div class="row">
        <h3 class="bootstrap-table" style="font-weight: normal;">打卡查詢</h3>
        <div class="toolbar form-horizontal bootstrap-table">
            <div class="form-group form-inline">
                <div class="input-group ">
                    <label for="inputl3" class="control-label">日期</label>
                </div>
                <div class="input-group col-md-3">
                    <input type="text" id="start" name="start" class="datepicker form-control" />
                    <span class="input-group-addon">～</span>
                    <input type="text" id="end" name="end" class="datepicker form-control" />
                </div>

                <div class="input-group col-md-6">
                    <span id="dcoddep" style="display: none;">
                        <div class="input-group">
                            <label for="inputl" class="control-label">組別</label>
                        </div>
                        <div class="input-group col-md-2">
                            <select id="coddep" name="coddep">
                                <option></option>
                            </select>
                        </div>
                    </span>
                    <div class="input-group col-md-2">
                        <button type="button" class="btn btn-primary " onclick="search()" id="xsearch">搜尋</button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <input id="Hidden1" type="hidden" />
    <div class="row">
        <div style="overflow: auto">
            <div style="width: 1950px">
                <table id="checklist">
                </table>
            </div>
        </div>
    </div>
</asp:Content>
