using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace HR.DBUtility.Models
{
    public class User
    {

        /// <summary>
        /// 員工工號 (ERP版本)
        /// </summary>
        public string Username { get; set; }
        /// <summary>
        /// 員工工號 (文中版本)
        /// </summary>
        public string Username2 { get; set; }
        /// <summary>
        /// 員工姓名 
        /// </summary>
        public string CNname { get; set; }
        /// <summary>
        /// 目前登入使用者的context
        /// </summary>
        public HttpContext context { get; set; }

        public User(HttpContext context)
        {
            this.context = context;
            Username = context.Session["username"]?.ToString() ?? "";
            Username2 = Username.Equals("A02") ? "A02" : Username.TrimStart('0').PadLeft(4, '0');
            CNname = context.Session["CNname"]?.ToString() ?? "";
        }
    }


    //職位
    public enum Position
    {
        /// <summary>
        /// 一般職員
        /// </summary>
        GENERAL,
        /// <summary>
        /// 組長
        /// </summary>
        LUSER,
        /// <summary>
        /// 課長
        /// </summary>
        SUSER,
        /// <summary>
        /// 副理
        /// </summary>
        DUSER,
        /// <summary>
        /// 經理
        /// </summary>
        MUSER,
        /// <summary>
        /// 總經理
        /// </summary>
        GUSER
    }
}
