<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="people.aspx.cs" Inherits="全傳請假系統.hrHome2_test1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>簽核流程維護程式</title>

    <link href="CSS/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <script src="js/jquery/jquery-3.1.1.min.js"></script>
    <link href="CSS/bootstrap-table/bootstrap-table.css" rel="stylesheet" />
    <link href="CSS/chosen/chosen.css" rel="stylesheet" />

    <script src="js/jquery/chosen/chosen.jquery.js"></script>
    <script src="js/jquery/ga.js"></script>
    <link href="CSS/select2/select2.css" rel="stylesheet" />

    <style>
        th, td {
            text-align: center;
        }

        .auto-style1 {
            height: 20px;
        }

        .hiddencol {
            display: none;
        }
    </style>
</head>


<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>


        <div class="modal fade" id="modal2">
            <%--modal fade 會影響chosen--%>
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-body">
                        <div class="container-fluid text-center">
                            <div class="form-group">
                                <%--<asp:DropDownList ID="DropDownList5" CssClass="form-control" style="width:170px" runat="server" DataSourceID="SqlDataSource2" DataTextField="CONTEN" DataValueField="STN_WORK"></asp:DropDownList>--%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <br />
        <div class="container">
            <h3>人員歸屬表</h3>
        </div>
        <div class="container">
            <div id="toolbar" class="btn-group">
                <%--            <button id="btn_add" type="button" class="btn btn-default" data-toggle="modal" data-target="#modal1" runat="server">
                <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>單筆修改
            </button>--%>
                <button id="btn_edit" type="button" class="btn btn-default" data-toggle="modal" data-target="#modal3" runat="server">
                    <span class="glyphicon glyphicon-check" aria-hidden="true"></span>給予歸屬
                </button>
            </div>
            <br />
            <br />

            <table
                id="table1"
                data-height="430"
                data-pagination="true"
                data-search="true"
                data-click-to-select="true"
                data-select-item-name="selectItemName">

                <thead>
                    <tr>
                        <th data-checkbox="true"></th>
                        <th data-field="Username">工號 </th>
                        <th data-field="CNname">姓名</th>
                        <th data-field="dpt">組別</th>
                        <th data-field="q2">TBI1 / TBI2</th>
                        <th data-field="a2">歸屬</th>
                        <%--<th>班長、組長</th>
                                    <th>課長</th>
                                    <th>副理</th>
                                    <th>經理</th>
                                    <th>總經理</th>--%>
                    </tr>
                </thead>
            </table>
            <br />
            <hr />

            <h3>部門主管歸屬表</h3>
            <div class="btn-group">
                <button id="XInsert" type="button" class="btn btn-primary" data-toggle="modal" data-target="#InsertModal">新增歸屬</button>
                <button id="XUpdate" type="button" class="btn btn-default" data-toggle="modal" data-target="#UpdateModal" disabled="disabled">修改歸屬</button>
                <button id="XDelete" type="button" class="btn btn-default" data-toggle="modal" data-target="#DeleteModal" disabled="disabled">刪除歸屬</button>
            </div>
            <table
                id="table2"
                data-height="430"
                data-search="true"
                data-pagination="true">

                <thead>
                    <tr>
                        <th data-field="ID" class="hiddencol">ID</th>
                        <th data-field="ProgramName">程式預設代碼</th>
                        <th data-field="STN_WORK" class="hiddencol">部門代號</th>
                        <th data-field="dpt">組別</th>
                        <%--<th data-field="deptctl">TBI1/TBI2</th>--%>
                        <th data-field="ProgNo">歸屬</th>
                        <th data-field="Monitor">班長、組長</th>
                        <th data-field="LUSERID" class="hiddencol">班長、組長(工號)</th>
                        <th data-field="Chief">課長</th>
                        <th data-field="SUSERID" class="hiddencol">課長(工號)</th>
                        <th data-field="DeputyManager">副理</th>
                        <th data-field="DUSERID" class="hiddencol">副理(工號)</th>
                        <th data-field="Manager">經理</th>
                        <th data-field="MUSERID" class="hiddencol">經理(工號)</th>
                        <th data-field="GeneralManager">總經理</th>
                        <th data-field="AddTime" class="hiddencol">新增時間</th>

                    </tr>
                </thead>
            </table>
            <br />
            <br />
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="SELECT ProgramName, STN_WORK, CONTEN, deptctl, ProgNo, LUSERID, SUSERID, DUSERID, MUSERID, GUSERID FROM tbi.dbo.XSingOrd X, tbi.dbo.Winton_mf2000 W where mf200 = STN_WORK"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="SELECT DISTINCT PROGRAMNAME, STN_WORK ,CONTEN FROM tbi.dbo.XSingOrd X, tbi.dbo.Winton_mf2000 W where mf200 = STN_WORK"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="SELECT DISTINCT [deptctl] FROM [XSingOrd]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource4" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="SELECT DISTINCT [ProgNo] FROM [XSingOrd]"></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource5" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand=""></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource6" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="SELECT ProgramName, STN_WORK, CONTEN, deptctl, ProgNo, LUSERID, SUSERID, DUSERID, MUSERID, GUSERID FROM tbi.dbo.XSingOrd X, tbi.dbo.Winton_mf2000 W where mf200 = STN_WORK "></asp:SqlDataSource>
        <asp:SqlDataSource ID="SqlDataSource7" runat="server" ConnectionString="<%$ ConnectionStrings:tbiConnectionString %>" SelectCommand="select DISTINCT U.Username, mf200, U.CNname,a1 ,W.CONTEN , U.q2 , U.a2, X.SUSERID , X.DUSERID , X.MUSERID , X.GUSERID  from tbi.dbo.XSingOrd X, tbi.dbo.Users U, tbi.dbo.Winton_mf2000 W where a1 = hrs and STN_WORK = mf200 and DAT_LIME > @vv order by mf200">
            <SelectParameters>
                <asp:SessionParameter Name="vv" SessionField="vv" Type="String" />
            </SelectParameters>
        </asp:SqlDataSource>

        <!-- ***************************************** 修改開始 ******************************************* -->

        <div class="modal fade" id="modal1" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">修改人員歸屬</h4>
                    </div>

                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group text-center">
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    程式預設代碼
                                </div>
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" Style="width: 170px" ReadOnly="True"></asp:TextBox>
                                </div>
                                <br />
                                <br />
                                <hr />
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    組別
                                </div>


                                <!-- ***************************************** 修改-組別開始 ******************************************* -->


                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <select id="ddl1" class="form-control" runat="server" style="width: 170px" name="DropDownList1" onblur="tlf()">
                                    </select>
                                </div>
                                <!-- ***************************************** 修改-組別結束 ******************************************* -->
                                <br />
                                <br />
                                <hr />
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    組員
                                </div>

                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <select id="ddl2" runat="server" class="form-control" style="width: 170px" name="test" data-placeholder="選擇人員">
                                        <option>請選擇組員</option>
                                    </select>
                                </div>
                                <br />
                                <br />
                                <hr />
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    歸屬
                                </div>
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <%--   <asp:DropDownList ID="DropDownList3" CssClass="form-control" style="width:170px" runat="server" DataSourceID="SqlDataSource4" DataTextField="ProgNo" DataValueField="ProgNo" AppendDataBoundItems = "true">
                                        <asp:ListItem Value="0">請選擇歸屬</asp:ListItem>
                                    </asp:DropDownList>--%>
                                </div>
                                <br />
                                <br />
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" id="insertbtn" class="btn btn-primary">確認</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                    <!-- modal-footer -->
                </div>
                <!-- modal-body -->
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
        </div><!-- /.modal -->
        <!-- ***************************************** 修改結束 ******************************************* -->

        <!-- ***************************************** 批次修改開始 ******************************************* -->

        <div class="modal fade" id="modal3" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <%--style ="width: auto"--%>
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">批次修改人員歸屬</h4>
                    </div>

                    <div class="modal-body">
                        <div class="container-fluid">
                            <div class="form-group text-center">
                                <div class="col-lg-12 col-sm-12 col-xs-12">
                                    <h4>修改已勾選的人員</h4>
                                </div>
                                <br />
                                <br />
                                <hr />
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    程式預設代碼
                                </div>
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control" Style="width: 170px" ReadOnly="True"></asp:TextBox>
                                </div>
                                <br />
                                <br />
                                <hr />
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    歸屬
                                </div>
                                <div class="col-lg-6 col-sm-6 col-xs-6">
                                    <%--   <asp:DropDownList ID="ddl4" CssClass="form-control" style="width:170px" runat="server" DataSourceID="SqlDataSource4" DataTextField="ProgNo" DataValueField="ProgNo" AppendDataBoundItems = "true">
                                        <asp:ListItem Value="0">請選擇歸屬</asp:ListItem>
                                    </asp:DropDownList>--%>
                                    <select id="ddl4" class="form-control" style="width: 170px" name="ddl4">
                                    </select>

                                </div>
                                <br />
                                <br />
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer">
                        <button type="button" id="multibtn" class="btn btn-primary">確認</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                    <!-- modal-footer -->
                </div>
                <!-- modal-body -->
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
        </div><!-- /.modal -->
        <!-- ***************************************** 批次修改結束 ******************************************* -->
        <!-- ***************************************** 新增歸屬開始 ******************************************* -->

        <div class="modal fade" id="InsertModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">新增歸屬</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <div class="container">
                                <div class="form-group">
                                    <div class="input-group">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">程式預設代碼</label>
                                        </div>
                                        <div class="input-group ">
                                            <input type="text" id="ProgramName" class="form-control" value="WPA60" readonly="readonly" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">組別</label>
                                        </div>
                                        <div class="input-group col-md-3">
                                            <select id="InsertDpt" class="form-control"></select>
                                        </div>

                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">歸屬代號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3 col-md-3">
                                            <input id="ProgNo" type="text" class="form-control" />
                                        </div>
                                    </div>

                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">組長、班長工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="LuserId" type="text" class="form-control" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">課長工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="SuserId" type="text" class="form-control" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">副理工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="DuserId" type="text" class="form-control" />
                                        </div>
                                    </div>

                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">經理工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="MuserId" type="text" class="form-control" />
                                        </div>
                                    </div>
                                    <%--<div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">總經理工號</label>
                                    </div>
                                    <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                        <input id="GuserId" class="form-control" />
                                    </div>
                                </div>--%>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">新增人工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="InsertUser" type="text" class="form-control" />
                                        </div>
                                    </div>
                                </div>
                                <!-- form-group form-inline -->
                            </div>
                            <!-- container -->
                        </div>
                        <!-- form-horizontal -->
                    </div>
                    <!-- modal-body -->

                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" id="Insert">確認</button>
                        <button type="button" class="btn btn-default" id="Close" data-dismiss="modal">關閉</button>
                    </div>
                    <!-- modal-footer -->
                </div>
                <!-- modal-content -->
            </div>
            <!-- modal-dialog -->
        </div>
        <!-- modal fade -->


        <!-- ***************************************** 新增歸屬結束 ******************************************* -->
        <!-- ***************************************** 修改歸屬開始 ******************************************* -->

        <div class="modal fade" id="UpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">修改歸屬</h4>
                    </div>
                    <div class="modal-body">
                        <div class="form-horizontal">
                            <div class="container">
                                <div class="form-group">
                                    <div class="input-group">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">程式預設代碼</label>
                                        </div>
                                        <div class="input-group ">
                                            <input type="text" id="ProgramName2" class="form-control" value="WPA60" readonly="readonly" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">組別</label>
                                        </div>
                                        <div class="input-group col-md-3">
                                            <select id="UpdateDpt" class="form-control"></select>
                                        </div>

                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">歸屬代號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3 col-md-3">
                                            <input id="ProgNo2" class="form-control" />
                                        </div>
                                    </div>

                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">組長、班長工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="LuserId2" class="form-control" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">課長工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="SuserId2" class="form-control" />
                                        </div>
                                    </div>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">副理工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="DuserId2" class="form-control" />
                                        </div>
                                    </div>

                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label">經理工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="MuserId2" class="form-control" />
                                        </div>
                                    </div>
                                    <%--<div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                    <div class="input-group">
                                        <label for="inputl" class="control-label">總經理工號</label>
                                    </div>
                                    <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                        <input id="GuserId2" class="form-control" />
                                    </div>
                                </div>--%>
                                    <div class="input-group col-md-12 col-sm-12" style="margin-top: 10px">
                                        <div class="input-group">
                                            <label for="inputl" class="control-label" style="color: red">*</label><label for="inputl" class="control-label">修改人工號</label>
                                        </div>
                                        <div class="input-group col-xs-3 col-sm-3 col-lg-3">
                                            <input id="UpdateUser" class="form-control" />
                                        </div>
                                    </div>

                                </div>
                                <!-- form-group -->
                            </div>
                            <!-- container -->
                        </div>
                        <!-- form-horizontal -->
                    </div>
                    <!-- modal-body -->

                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" id="Update">確認</button>
                        <button type="button" class="btn btn-default" id="Close2" data-dismiss="modal">關閉</button>
                    </div>
                    <!-- modal-footer -->
                </div>
                <!-- modal-content -->
            </div>
            <!-- modal-dialog -->
        </div>
        <!-- modal fade -->

        <!-- ***************************************** 修改歸屬結束 ******************************************* -->
        <!-- ***************************************** 刪除開始 ******************************************* -->

        <div class="modal fade" id="DeleteModal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 300px">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">X</span></button>
                        <h4 class="modal-title">刪除歸屬</h4>
                    </div>
                    <div class="modal-body">
                        <h1 style="color: #FF0000; font-size: x-large; text-align: center">確定要刪除嗎?</h1>
                    </div>
                    <div class="modal-footer">
                        <button id="Delete" type="button" class="btn btn-primary" data-dismiss="modal">確認</button>
                        <button type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
        <!-- /.modal -->

        <!-- ***************************************** 刪除結束 ******************************************* -->



        <script type="text/javascript">
            $(function btn_reset() {
                $('#btn_reset').click(function () {
                    location.href = 'people.aspx';
                });
            });

            $(function () {
                //雙層下拉連動
                //宣告一個全域陣列data2
                var data2 = [];

                $(document).ready(function () {
                    Page_Init();
                });
                //頁面載入時執行
                function Page_Init() {
                    $.ajax({
                        async: false,
                        url: 'Tools/ddlsql.ashx?mode=DDL1',
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8'
                    }).then(function (response) {
                        $('#ddl1').empty().append($('<option></option>').val('0').text('請選擇組別'));

                        data: $.map(response, function (obj) {

                            $('#ddl1').append($('<option></option>').val(obj.hrs).text(obj.dpt));
                            return obj;
                        })

                    });
                    //設定ddl2的預設值
                    $('#ddl2').empty().append($('<option></option>').val('0').text('請選擇組員'));
                    $('#ddl4').empty().append($('<option></option>').val('0').text('請選擇歸屬'));
                    $('#InsertDpt').empty().append($('<option></option>').val('0').text('請選擇組別'));
                    $('#UpdateDpt').empty().append($('<option></option>').val('0').text('請選擇組別'));
                    $.ajax({
                        async: false,
                        url: 'Tools/ddlsql.ashx?mode=DDL4',
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8'
                    }).then(function (response) {

                        data: $.map(response, function (obj) {
                            $('#ddl4').append($('<option></option>').val(obj.ProgNo).text(obj.ProgNo));
                            return obj;
                        })

                    });
                    $.ajax({
                        async: false,
                        url: 'Tools/ddlsql.ashx?mode=SelectDpt',
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8'
                    }).then(function (response) {

                        data: $.map(response, function (obj) {
                            $('#InsertDpt').append($('<option></option>').val(obj.mf200).text(obj.dpt));
                            $('#UpdateDpt').append($('<option></option>').val(obj.mf200).text(obj.dpt));
                            return obj;
                        })

                    });

                    //宣告ddl1.change事件
                    $('#ddl1').change(function () {
                        ChangeDdl1();
                    });

                    //載入ddl2的json資料
                    GetDdl2JsonData();

                }

                function GetDdl2JsonData() {
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/ddlsql.ashx?mode=DDL2',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8',
                        success: function (data) {
                            data2 = data;
                        }
                    });
                    return data2;
                }


                function ChangeDdl1() {
                    //變動動第一個下拉選單之後，便清空(empty)第二個下拉的內容，並添加預設值(--------)進去
                    $('#ddl2').empty().append($('<option></option>').val('0').text('請選擇組員'));

                    //取得第一個下拉選單被選取之選項的value與text
                    var hrs = $.trim($('#ddl1 option:selected').val());
                    var dpt = $.trim($('#ddl1 option:selected').text());
                    $('#Label1').text(hrs);
                    //將剛剛轉成Array的data2放到.grep()中，這是過濾Array中的資料，並把符合條件(return)的資料取出
                    var getData2 = $.grep(data2, function (item, i) {
                        return item["a1"] == hrs;
                    });

                    //使用遍歷工具 $.each 把剛剛篩選好的Array資料做進一步處理
                    //注意!! $.grep是function(item,i) 而 each為function(i,item)千萬小心
                    $.each(getData2, function (i, item) {
                        $('#ddl2').append($('<option></option>').val(item["Username"]).text(item["Users"]));
                    });

                }

                $('#ddl2').change(function () {
                    var Username = $.trim($('#ddl2 option:selected').val());
                    var CNname = $.trim($('#ddl2 option:selected').text());
                });
                /********************************************* 個人修改 **************************************************/
                $('#insertbtn').click(function () {
                    var ddl1 = document.getElementById("ddl1").value;
                    var ddl2 = document.getElementById("ddl2").value;
                    var ddl3 = document.getElementById("DropDownList3").value;

                    if (ddl1 == '0') {
                        alert('請選擇組別');
                    }
                    else if (ddl2 == '0') {
                        alert('請選擇人員');
                    }
                    else if (ddl3 == '0') {
                        alert('請選擇歸屬');
                    }
                    else {
                        $.ajax({
                            url: 'Tools/ddlsql.ashx?ddl2=' + ddl2 + '&ddl3=' + ddl3,
                            type: 'POST',
                            dataType: 'json',
                            contentType: 'application/json; charset=utf-8',
                        });
                        location.href = 'people.aspx';
                    }

                });
                /********************************************* 批次修改 **************************************************/

                $('#multibtn').click(function () {

                    var checked;
                    try {
                        $.each($('input[name="selectItemName"]:checked'), function () {
                            var check = $(this).closest('tr').find('td:nth-child(2)').text();
                            var ddl4 = $('#ddl4').val();
                            checked = check;
                            if (ddl4 == '請選擇歸屬') {
                                alert('尚未選擇歸屬');
                                return;
                            }
                            else {
                                $.ajax({
                                    type: 'POST',
                                    url: 'Tools/ddlsql.ashx?check=' + checked + '&ddl4=' + ddl4,
                                    async: false,
                                    contentType: 'application/json; charset=utf-8'
                                }).done(function (msg) {
                                    $('#modal3').modal('hide')
                                });
                            }
                        });
                        $('#table1').bootstrapTable('refresh', { url: 'Tools/ddlsql.ashx?mode=table1&a=' + Math.random() });
                    } finally {
                        if (checked == null) {

                            alert('尚未選取人員');
                        }
                    }


                });

                //取得table1資料
                $(function () {
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/ddlsql.ashx?mode=table1',
                        dataType: 'json',
                        contentType: 'application/json; charset=utf-8',
                        success: function (data1) {
                            //將資料投到table1中
                            $('#table1').bootstrapTable({ data: data1 });
                        }
                    });
                });

                //取得table2資料
                $(function () {
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/ddlsql.ashx?mode=table2',
                        dataType: 'json',
                        success: function (data2) {
                            $('#table2').bootstrapTable({ data: data2 });
                        }
                    });
                });
                /*****************************************************新增歸屬**********************************************************/
                $('#Insert').click(function () {
                    var InsertDpt = $('#InsertDpt').val();//組別
                    var ProgNo = $('#ProgNo').val();//歸屬代號
                    var LuserId = $('#LuserId').val();//組長、班長
                    var SuserId = $('#SuserId').val();//課長
                    var DuserId = $('#DuserId').val();//副理
                    var MuserId = $('#MuserId').val();//經理
                    //var GuserId = $('#GuserId').val();//總經理
                    var InsertUser = $('#InsertUser').val();//新增人

                    if (LuserId == '') {
                        LuserId = '';
                    } if (SuserId == '') {
                        SuserId = '';
                    }
                    if (DuserId == '') {
                        DuserId = '';
                    }
                    if (MuserId == '') {
                        MuserId = '';
                    }
                    if (InsertDpt == '0') {
                        alert('請選擇組別');
                    } else if (ProgNo == '') {
                        alert('請填寫歸屬代號');
                    } else if (ProgNo.length > 3) {
                        alert('歸屬代號只能3位數喔');
                    } else if (InsertUser == '') {
                        alert('請在「新增人工號」欄位填寫您的工號');
                    } else {
                        $.ajax({
                            type: 'POST',
                            url: 'Tools/ddlsql.ashx?mode=Insert&InsertDpt=' + InsertDpt + '&ProgNo=' + ProgNo + '&LuserId=' + LuserId + '&SuserId=' + SuserId + '&DuserId=' + DuserId + '&MuserId=' + MuserId + '&InsertUser=' + InsertUser,
                            success: (function (data) {
                                $('#InsertModal').modal('hide');
                                $('#table2').bootstrapTable('refresh', { url: 'Tools/ddlsql.ashx?mode=table2' });
                            }), error: (function (data2) {
         
                            })
                        });
                    }
                });
                /*****************************************************修改歸屬**********************************************************/

                //修改按鈕資料帶入
                $('#table2').on('click-row.bs.table', function (e, row, $element) {
                    $('.warning').removeClass('warning');
                    $($element).addClass('warning');
                });
                function getMSelectedRow(xxx) {
                    var index = xxx.find('tr.warning').data('index');
                    return xxx.bootstrapTable('getData')[index];
                }

                //修改、刪除按鈕解鎖
                $('#table2').on('click-row.bs.table', function () {
                    // var get = getMSelectedRow($('#table2'));
                    $('#XUpdate').attr('disabled', false);
                    $('#XDelete').attr('disabled', false);

                });
                $('#XUpdate').click(function () {
                    var get = getMSelectedRow($('#table2'));
                    var ID = get.ID;
                    var ProgNo = $('#ProgNo2').val(get.ProgNo);
                    $('#UpdateDpt').val(get.STN_WORK);
                    $('#ProgNo2').val(get.ProgNo);
                    $('#LuserId2').val(get.LUSERID);
                    $('#SuserId2').val(get.SUSERID);
                    $('#DuserId2').val(get.DUSERID);
                    $('#MuserId2').val(get.MUSERID);

                    
                });
                $('#Update').click(function () {


                    var get = getMSelectedRow($('#table2'));
                    var ID = get.ID;
                    

                    var UpdateDpt = $('#UpdateDpt').val();//組別
                    var ProgNo2 = $('#ProgNo2').val();//歸屬代號
                    var LuserId2 = $('#LuserId2').val();//組長、班長
                    var SuserId2 = $('#SuserId2').val();//課長
                    var DuserId2 = $('#DuserId2').val();//副理
                    var MuserId2 = $('#MuserId2').val();//經理
                    var UpdateUser = $('#UpdateUser').val();//修改人 

                    if (ProgNo.length > 3) {
                        alert('歸屬代號只能3位數喔');
                    } else if (UpdateUser == '') {
                        alert('請在「修改人工號」欄位填寫您的工號');
                    }
                    else {
                        $.ajax({
                            type: 'POST',
                            url: 'Tools/ddlsql.ashx?mode=Update&ID=' + ID + '&UpdateDpt=' + UpdateDpt + '&ProgNo2=' + ProgNo2 + '&LuserId2=' + LuserId2 + '&SuserId2=' + SuserId2 + '&DuserId2=' + DuserId2 + '&MuserId2=' + MuserId2 + '&UpdateUser=' + UpdateUser,
                            success: (function (data) {
                                $('#UpdateModal').modal('hide');
                                $('#table2').bootstrapTable('refresh', { url: 'Tools/ddlsql.ashx?mode=table2' });
                            }),
                            error: (function (data2) {

                            })
                        });
                    }
                });
                /*****************************************************刪除歸屬**********************************************************/
                $('#Delete').click(function () {
                    var get = getMSelectedRow($('#table2'));
                    var ID = get.ID;
                    $.ajax({
                        type: 'POST',
                        url: 'Tools/ddlsql.ashx?mode=Delete&ID=' + ID,
                        success: (function (data) {
                            $('#DeleteModal').modal('hide');
                            $('#table2').bootstrapTable('refresh', { url: 'Tools/ddlsql.ashx?mode=table2' });
                        }),
                        error: (function (data2) {
                      
                        })
                    });
                });
            });
        </script>


    </form>
    <script src="js/bootstrap/bootstrap.min.js"></script>
    <script src="js/bootstrap-table/bootstrap-table.js"></script>
    <script src="js/select2/select2.js"></script>

</body>
</html>
