using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace 全傳請假系統
{
    public partial class hrHome2_test1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DateTime vv = DateTime.Now;
            Session["vv"] = vv;
            TextBox1.Text = "WPA60";
            TextBox2.Text = "WPA60";
        }
    }
}