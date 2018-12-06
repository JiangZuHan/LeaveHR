using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace 全傳請假系統
{
    public partial class select2_produceline : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] == null)
            {
                Response.Write("<script>alert('登入時限已到，請重新登入');location.href='Login.aspx';</script>");
            }
            else if (Session["UserName"] != null)
            {
                Label1.Text = "登入時間：" + Session["time"].ToString();
            }
        }
    }
}