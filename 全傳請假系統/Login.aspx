<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="全傳請假系統.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>請假系統</title>
    <link href="CSS/style.css" rel="stylesheet" />
    <link href="CSS/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <link href="CSS/bootstrap-dialog.min.css" rel="stylesheet" />
    <link href="CSS/jquery.isloading.css" rel="stylesheet" />
    <%--    <script src="js/jquery/jquery-1.11.3.min.js"></script>--%>
    <%--<script src="js/bootstrap/bootstrap.min.js"></script>--%>
    <%--<script src="js/bootstrap-dialog.min.js"></script>--%>
    <%--<script src="js/jquery.isloading.js"></script>--%>

    <style>
        #tip {
            position: absolute;
            /*height: 25px;*/
            padding: 5px;
            text-align: center;
            display: none;
            color: red;
            border: 1px solid #dad699;
            background: #f9f5c7;
            border-radius: 3px;
            font-size: 8px;
            /*right:217px;*/
            -moz-box-shadow: 0.3px 0.3px 1px 1px rgba(0, 0, 0, 0.4);
            -webkit-box-shadow: 0.3px 0.3px 1px 1px rgba(0, 0, 0, 0.4);
            box-shadow: 0.3px 0.3px 1px 1px rgba(0, 0, 0, 0.4);
        }
    </style>
    <script src="<%=ResolveClientUrl("~/js/jquery/jquery-1.11.3.min.js")%>"></script>
    <script src="<%=ResolveClientUrl("~/js/bootstrap/bootstrap.min.js")%>"></script>
    <script src="<%=ResolveClientUrl("~/js/bootstrap-dialog.min.js")%>"></script>
    <script src="<%=ResolveClientUrl("~/js/jquery.isloading.js")%>"></script>

    <script>

        $(document).ready(function () {

            //var txtPassword = $("#Password");
            //function show(id) {
            //    var ele = $("#" + id + "");
            //    $(ele).css("display", "block");
            //    $(ele).css("left", event.clientX);
            //    $(ele).css("top", event.clientY + 15);
            //}
            //function hide(id) {
            //    var ele = $("#" + id + "");
            //    $(ele).css("display", "none");
            //}
            //var isCapslockOn;
            //function checkCapsLock_keyPress(e) {
            //    var e = event || window.event;
            //    var keyCode = e.keyCode || e.which;//按键的keyCode。  
            //    var isShift = e.shiftKey || (keyCode == 16) || false;//shift键是否按住。  
            //    if (
            //    ((keyCode >= 65 && keyCode <= 90) && !isShift) // CapsLock打开，且没有按住shift键。  
            //    || ((keyCode >= 97 && keyCode <= 122) && isShift))// CapsLock打开，且按住shift键。  
            //        isCapslockOn = true;
            //    else
            //        isCapslockOn = false;
            //}
            //function checkCapsLock_keydown(e) {
            //    var keyCode = window.event ? e.keyCode : e.which;
            //    if (keyCode == 20 && isCapslockOn == true)
            //        isCapslockOn = false;
            //    else if (keyCode == 20 && isCapslockOn == false)
            //        isCapslockOn = true;
            //}
            //function tip() {
            //    if (isCapslockOn)
            //        show("tip");
            //    else
            //        hide("tip");
            //}
            ////keyPress可以判断当前CapsLock状态，但不能捕获CapsLock键。  
            //$(document).keypress(checkCapsLock_keyPress);
            ////keyDown可以捕获CapsLock键，但不能判断CapsLock的状态。  
            //$(document).keydown(checkCapsLock_keydown);

            //txtPassword.keyup(tip).focus(function () {
            //    if (isCapslockOn) show("tip");
            //}).blur(function () {
            //    hide("tip");
            //});

            $("#Password").keypress(function (event) {
                if (event.keyCode == 13) {
                    $("#Login").trigger("click");
                }
            });
            $('#Login').click(function () {
                var account = document.getElementById('Account').value;
                var password = document.getElementById('Password').value;
                $.ajax({
                    type: 'POST',
                    url: 'Tools/Login.ashx?mode=Login',
                    data: {
                        'account': account,
                        'password':password
                    },
                    success: function (data) {

                        var home_url, paak;


                        if (isJson(data)) {
                            home_url = JSON.parse(data).url
                            paak = JSON.parse(data).paak
                        } else {
                            paak = data;
                        }


                        if (account != "" && password != "") {
                            if (paak != "False") {
                                if (paak > 0) {
                                    if (paak < 48) {
                                        if (paak == undefined) {
                                            alert('您在留職停薪期間，無法請假!');
                                        }

                                        location.href = home_url;
                                    } else {
                                        if (paak == undefined) {
                                            alert('您在留職停薪期間，無法請假!');
                                        }
                                        location.href = home_url;
                                    }
                                } else {
                                    $('#Label1').text('無使用權限!');
                                }
                            } else {
                                $('#Label1').text('帳號或密碼錯誤!');
                            }
                        } else {
                            $('#Label1').text('帳號密碼為必填!');
                        }
                    }
                });
            });

            //確認是否是 JSON
            function isJson(str) {
                try {
                    JSON.parse(str);
                } catch (e) {
                    return false;
                }
                return true;
            }

        });
    </script>
</head>
<body>
    <div class="wrapper">
        <div class="container">
            <h1 class="form-signin-heading">請假系統登入</h1>
            <div class="col-xs-12 col-sm-12">
                <form id="form1" runat="server" class="form-signin" role="form">
                    <div class="form-group">
                        <input id="Account" placeholder="Account" />
                        <br />
                        <input id="Password" class="input-group" type="password" placeholder="Password" />
                        <span id="tip">大寫鎖定已打開！</span>
                        <span id="Label1" style="color: red;"></span>
                        <%--<input id="txt" type="text" />--%>
                        <br />
                        <button id="Login" type="button" class="btn btn-lg btn-primary">登入</button>
                    </div>
                </form>
            </div>
        </div>
        <ul class="bg-bubbles">
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
            <li></li>
        </ul>
    </div>
</body>
</html>