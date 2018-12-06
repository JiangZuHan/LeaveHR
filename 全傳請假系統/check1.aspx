<%@ Page Title="" Language="C#" MasterPageFile="~/請假主版.Master" AutoEventWireup="true" CodeBehind="check1.aspx.cs" Inherits="全傳請假系統.check1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
</asp:Content>



<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <style type="text/css">
        #A02 {
            display: none;
        }
    </style>
    <div id="ontopDiv" class="container">

        <ul class="nav nav-tabs">
            <li role="presentation"><a href="<%Response.Write(Session["Home"]);%>">假單申請</a></li>
            <li role="presentation"><a href="AllecDoor.aspx">打卡查詢</a></li>
            <li role="presentation"><a href="<% Response.Write(Session["select2"]);%>">假單查詢</a></li>
            <%if (Session["check1"] != null)
                {
                    Response.Write("<li role='presentation' id='check' style='display: none' class='active'><a href='" + Session["check1"] + "'>行政待審核</a></li>");

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
            <asp:Label ID="Label19" runat="server" Text="登入時間"></asp:Label>

        </div>
    </div>

    <div class="container">
        <span style="font-size: 22px">本週人員出席狀況</span>
        <br />

        <div>
            <div class="text-right"><span>單位：人</span></div>
            <div style="overflow: auto">
                <div style="width: 1138px;">
                    <table id="test"></table>
                </div>
            </div>
        </div>
        <hr />
        <div class="modal fade" id="modalTable2" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
            <div class="modal-dialog" style="width: 90%;">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span></button>
                        <h4 class="modal-title">假單明細</h4>
                    </div>
                    <div class="modal-body">
                        <h4>當日請假</h4>
                        <div style="overflow: auto; align-content: center">
                            <div style="width: 1200px;">
                                <table id="ApprovalTable" class="table table-striped" data-toggle="table" data-pagination="true">
                                    <thead>
                                        <tr>
                                            <%--<th>班次</th>--%>
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
                                            <th data-field="PA60003" class="hiddencol">流水號</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button id="Close" type="button" class="btn btn-default" data-dismiss="modal">關閉</button>
                    </div>
                </div>
            </div>
        </div>
        <div id="wait">
            <span style="font-size: 22px">待審核</span>

            <br />
            <br />
            <button id="show" type="button" class="btn btn-success" style="font-size: large" disabled="disabled">核准</button>
            &nbsp;
                <button id="no" type="button" class="btn btn-danger" style="font-size: large" data-toggle="modal" data-target="#whynopassmodal" disabled="disabled">退件</button>
            &nbsp;
            <div id="bossone">

                <br />
                <br />
                <%-- 總經理 --%>
                <div style="overflow: auto">
                    <div style="width: 1138px;">
                        <table id="yee" class="table table-striped"
                            data-select-item-name="selectItemName"
                            data-click-to-select="true">
                        </table>
                    </div>
                </div>
                <br />
                <br />
            </div>

            <div id="bos">

                <br />
                <br />

                <%-- 一般主管 --%>
                <div style="overflow: auto">
                    <div style="width: 1138px;">
                        <table id="table" class="table table-striped"
                            data-select-item-name="selectItemName"
                            data-click-to-select="true">
                        </table>
                    </div>
                </div>
                <br />
                <br />
            </div>
        </div>
    </div>

    <div class="modal fade" id="whynopassmodal" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog" style="width: 300px">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">X</span></button>
                    <h4 class="modal-title">退件原因</h4>
                </div>
                <div class="modal-body">

                    <p>輸入退件的原因</p>
                    <br />
                    <br />
                    <textarea id="whynopasstext" class="form-control" style="height: 70px"></textarea>

                </div>
                <div class="modal-footer">
                    <button id="nopass" type="button" class="btn btn-default">確定</button>&nbsp;
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                </div>
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </div>
    <!-- /.modal -->
    <script> 
        //一般使用者誤入待審核防範措施
        if(  <%=  Convert.ToInt32(Session["CanCheck"]) %>==false)
        {
            location.href='Home.aspx';
        }

        //nav 上的待審核按鈕是否可見
        if(  <%=  Convert.ToInt32(Session["CanCheck"]) %>==true)
        {
            if(document.getElementById("check"))
                document.getElementById("check").style.display="block";  
            if(document.getElementById("check2"))
                document.getElementById("check2").style.display="block";  
        }


        $('#show').click(function () {
            var check = confirm('確定核准嗎?');
            if (check){
                var b,user,cnname,water,start,hr,hrmin,leave,death,d1 = 2;
                var size = 0;//陣列大小
                var hrarray = new Array();
                var userarray = new Array();
                var startarray = new Array();
                var waterarray = new Array();
                var cnnamearray = new Array();
                var leavearray = new Array();
                var deatharray = new Array();
                var check = new Array();//勾選的日期陣列
                //批次判斷username解決辦法(測試中)
                //篩選勾選的假單是否為喪假，如果是就把時數記錄起來，並把時數轉為分鐘
                $.each($('input[name="selectItemName"]:checked'), function() {
                    user = $(this).closest('tr').find('td:nth-child(2)').text();
                    cnname = $(this).closest('tr').find('td:nth-child(3)').text();
                    start = $(this).closest('tr').find('td:nth-child(5)').text(); 
                    water = $(this).closest('tr').find('td:nth-child(10)').text();
                    hr = $(this).closest('tr').find('td:nth-child(9)').text();
                    leave = $(this).closest('tr').find('td:nth-child(4)').text();
                    death = $(this).closest('tr').find('td:nth-child(13)').text();
                    // hrmin =  hr * 60;
                    $.each($('input[name="selectItemName"]:checked'), function() {
                        var date2 = new Date($(this).closest('tr').find('td:nth-child(5)').text().substr(0, 10));//將table的時間轉成日期
                        var date3 = date2.getFullYear() + '-' + (date2.getMonth() + 1 < 10 ? '0' : '') + (date2.getMonth() + 1) + '-' + (date2.getDate() < 10 ? '0' : '') + date2.getDate();
                        check.push("'" + date3 + "'");//將定義好的格式存進陣列
                    });
                    if(leave == '喪假'){//為了計算批次選取的總時數
                        hrarray[size] = hr;
                        userarray[size] = user;
                        startarray[size] = start;
                        waterarray[size] = water;
                        leavearray[size] = leave;
                        deatharray[size] = death;
                        cnnamearray[size] = cnname;
                        size = size+1;                                               
                    }else{                                                      
                        b = NoDeathYesPass(user,water,hr,leave,check);
                        if(b == "false"){
                            alert("「"+cnname+"」同仁的特休時數不夠了，煩請總經理點選 '退件' 謝謝您！");                        
                        }else if(b == "nonine"){
                            alert("「"+cnname+"」同仁沒有特休的餘額。煩請總經理點選 '退件' 謝謝您！");
                        }
                    }
                });
                //將上面記錄起來的各筆喪假分鐘數加總
                // var hrsum2 = hrsum.reduce((a, b) => a + b, 0); //Chrome，ES2015寫法
                var hrsum = hrarray.reduce(add, 0);

                function add(a, b) {
                    return a*1 + b*1;
                }                
                var a,Duser,Ddeath,Dleave,Dcnname,Dwater,Dhr;
                for(var i = 0; i < size;i++){
                    Duser = userarray[i];
                    Ddeath = deatharray[i];
                    Dleave = leavearray[i];
                    Dcnname = cnnamearray[i];
                    Dwater = waterarray[i];
                    Dhr = hrarray[i];
                    Dstart = startarray[i];
                    a = Deathcheck(Duser,Ddeath,hrsum,Dwater,Dstart);//判斷是否有剩餘時數 & 是否可以給予時數(選取總時數超過他的天數別總時數以及剩餘時數時)
                    if(a == 'hrsum'){
                        alert("「"+Dcnname+"」同仁所申請的「喪假」總時數已超過他所選的「天數："+Ddeath.substring(0,1)+"天」。煩請總經理點選 '退件' 謝謝您！");
                        return;
                    }    
                    else if(a == 'igt lefttime'){
                        alert('「'+Dcnname+'」同仁「喪假」剩餘時數不足，煩請總經理點選 "退件" 謝謝您！');
                        return;
                    }else if(a == 'water'){
                        alert('「'+Dcnname+'」同仁「'+Dstart+'」的喪假週期已結束，煩請總經理點選 "退件" 謝謝您！');
                        return;
                    }else if(a == '100'){
                        alert('「'+Dcnname+'」同仁「'+Dstart+'」的喪假已超過「百日」期限，煩請總經理點選 "退件" 謝謝您！');
                        return;
                    }else if (a == undefined){
                        alert('核准失敗');
                        return;
                    }
                    else if (a == 'HRS insert' || a == 'HRS update'){
                        $.ajax({
                            type: "POST",
                            async:false,//啟用同步請求
                            url: 'Tools/leaveuser.ashx?user=' + Duser + '&water=' + Dwater + '&hr=' + Dhr + '&pass=yes&leave=' + encodeURI(Dleave) + '&death=' + Ddeath + '&start=' + encodeURI(Dstart) + '&message=' + a + '&check=' + check, //(檔案名/方法名稱)
                            contentType: 'application/json; charset=utf-8'
                        }).success(function (response) {
                            hrsum = hrsum - Dhr;                           
                        }).error(function(data){
                            alert('流水號：'+Dwater+'核准失敗');
                        });                                                  
                    }                   
                }
                alert("審核成功！");
                setTimeout("location.href = 'check1.aspx';", 500);
            }
        });
        //-----------------------------------------------------------------------------------------
        $('#nopass').click(function () {
            var nopasstext = document.getElementById("whynopasstext").value;
            if(nopasstext == ""){
                alert("退件原因為必填，請填寫完後再送出！");
            }else{
                $.each($('input[name="selectItemName"]:checked'), function() {
                    var user = $(this).closest('tr').find('td:nth-child(2)').text(); //工號
                    var id = $(this).closest('tr').find('td:nth-child(4)').text(); //假別
                    var from = $(this).closest('tr').find('td:nth-child(5)').text(); //起
                    var to = $(this).closest('tr').find('td:nth-child(6)').text(); //迄
                    var cause = $(this).closest('tr').find('td:nth-child(7)').text(); //事由
                    var name = $(this).closest('tr').find('td:nth-child(8)').text(); //代理人
                    var hr = $(this).closest('tr').find('td:nth-child(9)').text(); //時數
                    var water = $(this).closest('tr').find('td:nth-child(10)').text(); //流水號

                    $.ajax({
                        type: "POST",
                        url: 'Tools/leaveuser.ashx?user=' + user + '&id=' + id +'&from='+ from + '&to=' + to +'&cause=' + cause +'&name=' + name + '&water=' + water + '&hr=' + hr + '&pass=no&nopasstext=' + encodeURI(nopasstext), //(檔案名/方法名稱)
                        contentType: 'application/json; charset=utf-8',
                    }).then(function (response) {
                        
                    }); 
                });
                alert("已退件！");
                setTimeout("location.href = 'check1.aspx';", 500);
            }            
        });
        function Deathcheck(Duser,Ddeath,hrsum,Dwater,Dstart){
            var data2;
            Dhrsum = hrsum * 60;
            $.ajax({
                type:'post',
                async: false,//啟用同步請求
                url:'Tools/process.ashx?mode=DeathDateType&user='+Duser+'&hrsum='+Dhrsum+'&death='+Ddeath+'&Dwater='+Dwater+'&Dstart='+encodeURI(Dstart),
                success:function(data){
                    data2 = data;
                }
            });          
            return data2;
        }
        function NoDeathYesPass(user,water,hr,leave,check){
            var data;
            $.ajax({
                type: "POST",
                async:false,
                url: 'Tools/leaveuser.ashx?user=' + user + '&water=' + water + '&hr=' + hr + '&pass=yes&leave='+encodeURI(leave) + '&check=' + check, //(檔案名/方法名稱)
                contentType: 'application/json; charset=utf-8',
            }).then(function (response) {
                data = response;
            });    
            return data;
        }        
        function imageFormatter(value) {

            if (value != '' && value != null) {
                return '<a target="_blank" href="' + value + '" download>點我</a>';
            }
        }
        //----------------------------------------------------------------------------------------        
        $(document).ready(function(){
            //---------------------------------------------------------------------------------
<%--            if (<%= Convert.ToInt32(Session["PAAK200"])%> > 49)
            {
                if(document.getElementById("wait") != null){
                  
                    document.getElementById("wait").style.display="none";
                }
            
            }--%>
            //---------------------------------------------------------------------------------
            if (<%= Convert.ToInt32(Session["PAAK200"])%> == 1)
            {
                document.getElementById("bos").style.display="none";
            
            }
            else{
                document.getElementById("bossone").style.display="none";
            }
            //---------------------------------------------------------------------------------
            //一週狀況
            $.ajax({
                type:'POST',
                url:'Tools/leaveuser.ashx?pass=dptall',
                dataType:'json',
                contentType:'application/json; charset=utf-8',
                success:(function(dptall){ 
                    $.ajax({
                        type:'POST',
                        url:'Tools/leaveuser.ashx?pass=leaveall',
                        dataType: 'json',
                        contentType:'application/json; charset=utf-8',
                        success:(function(leave){
                            $.ajax({
                                type:'POST',
                                url:'Tools/leaveuser.ashx?pass=week',
                                dataType:'json',
                                contentType:'application/json; charset=utf-8',
                                success:(function(week){
                                    $(function () {
                                        test1($('#test'), 8, 3);
                                    });

                                    function test1($table, cells, rows) {
                                        var i, j, row,a,
                                                columns = [],//拿來放thead的
                                                data = [],//拿來放tbody的  
                                                data2 = [];//拿來將'星期0'改成出席狀況的
                   
                                        for (i = 0; i < cells; i++) {//
                    
                                            columns.push({//宣告欄位名稱，塞入table
                                                field: '123' + i,//title的index
                                                title: '星期' + i,
                                                sortable: false//排序功能
                                            });                  
                                        }
                                        data2.push(columns);//先放入所有title，星期0~7               
                               
                                        var Today = Date(); 
                                        var qwe = Today.substring(0,3);
                                        $.each(data2,function(i,item){//將'星期0'改為出席狀況
                                            item[0].title = '';//原本為出席狀況
                                            item[1].title = week[0];
                                            item[2].title = week[1];
                                            item[3].title = week[2];
                                            item[4].title = week[3];
                                            item[5].title = week[4];
                                            item[6].title = week[5];
                                            item[7].title = week[6];
                                        });
                          
                                        //tbody
                                        for (i = 0; i < rows; i++) {
                                            row = {};
                                            for (j = 0; j < cells; j++) {                       
                                                row['123' + j] = 'Row-' + i + '-' + j;
                                                //應到人數
                                                if(row['123' + j] == 'Row-0-0')
                                                {
                                                    row['123' + j] = '應到';                                   
                                                }
                                                else if(row['123' +j] == 'Row-0-'+j)
                                                {                                                                    
                                                    row['123' + j] = dptall[0].dpt;                                                              
                                                }
                                                    //請假人數
                                                else if(row['123' + j] == 'Row-2-0')
                                                {
                                                    row['123' + j] = '請假';
                                                }
                                                else if(row['123' +j] == 'Row-2-'+j)
                                                {           
                                                    if(row['123' +j] != 'Row-2-0')
                                                    {
                                                        row['123' + j] = '<a id="Approval' + j + '" href="#modalTable2" data-toggle="modal">' + leave[j - 1].leave + '</a>';//因為已經排除2-0的狀況，所以能進到這個if的j一定大於0
                                                        if (leave[j - 1].leave == '0') {
                                                            row['123' + j] = leave[j - 1].leave;
                                                        }
                                                    }                                                         
                                                }
                                                    //實到人數
                                                else if(row['123' + j] == 'Row-1-0')
                                                {
                                                    row['123' + j] = '實到';
                                                }
                                                else if(row['123' +j] == 'Row-1-'+j)
                                                {                                                                    
                                                    row['123' + j] = dptall[0].dpt - leave[j-1].leave;                                                              
                                                }
                              
                                            }//for(j)
                                            //將tbody寫入data
                                            data.push(row);                   
                                        }
                                        //寫入table
                                        $table.bootstrapTable('destroy').bootstrapTable({//"destroy"→bootstrap-table.js的function
                                            columns: columns,
                                            data: data,
                                            fixedColumns: true,
                                            //fixedNumber: +$('#fixedNumber').val()//更改固定欄位數的input
                                        });
                                        $('#Approval1').click(function () {
                                            var week2 = week[0].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval2').click(function () {
                                            var week2 = week[1].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval3').click(function () {
                                            var week2 = week[2].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval4').click(function () {
                                            var week2 = week[3].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval5').click(function () {
                                            var week2 = week[4].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval6').click(function () {
                                            var week2 = week[5].substring(0, 10);
                                            Approval(week2);
                                        });
                                        $('#Approval7').click(function () {
                                            var week2 = week[6].substring(0, 10);
                                            Approval(week2);
                                        });
                                        function Approval(week2) {
                                            $('#ApprovalTable').bootstrapTable('refresh', {
                                                url: '/Tools/select.ashx?mode=Approval&week2=' + week2 + '&a=' + Math.random(),
                                                type: 'POST',
                                                contentType: 'application/json; charset=utf-8',
                                                dataType: 'json',
                                            });
                                        }
                                    }
                                })
                            });//一週日期week 
                        })
                    });//請假人數leave
                })
            });//部門人數dptall

            //審核中假單
            $.ajax({
                type:"POST",
                url:"Tools/leaveuser.ashx?pass=user",
                dataType:'json',
                contentType:'application/json; charset=utf-8',
                success:function(data){
                    $('#user').bootstrapTable({data: data});
                }
            });
            //總經理  
            $.ajax({
                type: "POST",
                url: 'Tools/leaveuser.ashx?pass=bossone', //(檔案名/方法名稱)
                dataType: 'json',
                contentType: 'application/json; charset=utf-8',
                success:function (data1) {
                    $('#yee').bootstrapTable({data: data1,
                        fixedColumns: true,
                        columns:[
                               {checkbox:true},
                               {field:'PA60002',title:'工號'},
                               {field:'CNname',title:'姓名'},
                               {field:'PA604',title:'假別'},
                               {field:'datefrom',title:'請假起始日'},
                               {field:'dateto',title:'請假結束日'},
                               {field:'PA60016',title:'事由'},
                               {field:'PA60038',title:'職務代理人'},
                               {field:'hrtime',title:'時數'},
                               {field:'PA60003',title:'流水號',class:'hiddencol'},
                               {field:'PA60039',title:'假別編號',class:'hiddencol'},
                               {field:'PA60040',title:'附件',
                                   formatter:function(value){
                                       if(value != ''){
                                           return'<a target="_blank" href="'+value+'" download>點我</a>';
                                       }
                                   }
                               },
                               {field:'PA60044',title:'喪假時數',class:'hiddencol'}
                        ]
                    });
                    if (data1.length == 1) {
                        $('#yee').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#yee').on('check.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#yee').on('uncheck.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                        $('#yee').on('uncheck-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                    } else if (data1.length == 0) {
                        $('#yee').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                    } else {
                        $('#yee').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#yee').on('check.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#yee').on('uncheck-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                        $('#yee').on('uncheck.bs.table', function () {
                            if ($('input[name="selectItemName"]:checked').length == 0) {
                                $('#show').attr('disabled', true);
                                $('#no').attr('disabled', true);
                            }
                        });
                    }
                }
            });
           
            //部門主管
            $.ajax({
                type:'POST',
                url:'Tools/leaveuser.ashx?pass=bos',
                dataType:'json',
                contentType:'applicateion/json; charset=utf-8',
                success:function(data2){

                    $('#table').bootstrapTable({data: data2,
                        fixedColumns: true,
                        columns:[
                            {checkbox:true},
                            {field:'PA60002',title:'工號'},
                            {field:'CNname',title:'姓名'},
                            {field:'PA604',title:'假別'},
                            {field:'datefrom',title:'請假起始日'},
                            {field:'dateto',title:'請假結束日'},
                            {field:'PA60016',title:'事由'},
                            {field:'PA60038',title:'職務代理人'},
                            {field:'hrtime',title:'時數'},
                            {field:'PA60003',title:'流水號',class:'hiddencol'},
                            {field:'PA60039',title:'假別編號',class:'hiddencol'},
                            {field:'PA60040',title:'附件',
                                formatter:function(value){
                                    if(value != ''){
                                        return'<a target="_blank" href="'+value+'" download>點我</a>';
                                    }
                                }
                            },
                               {field:'PA60044',title:'喪假時數',class:'hiddencol'}
                        ]
                    });
                    if (data2.length == 1) {
                        $('#table').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#table').on('check.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#table').on('uncheck.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                        $('#table').on('uncheck-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                    } else if (data2.length == 0) {
                        $('#table').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                    } else {
                        $('#table').on('check-all.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#table').on('check.bs.table', function () {
                            $('#show').attr('disabled', false);
                            $('#no').attr('disabled', false);
                        });
                        $('#table').on('uncheck-all.bs.table', function () {
                            $('#show').attr('disabled', true);
                            $('#no').attr('disabled', true);
                        });
                        $('#table').on('uncheck.bs.table', function () {
                            if ($('input[name="selectItemName"]:checked').length == 0) {
                                $('#show').attr('disabled', true);
                                $('#no').attr('disabled', true);
                            }
                        });
                    }
                }
            });


        });
   
    </script>
</asp:Content>

