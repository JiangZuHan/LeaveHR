using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace HR.DBUtility.Models
{
    public class SendSupervisorModal
    {
        /// <summary>
        /// 工號
        /// </summary>
        public string Username { get; set; }
        /// <summary>
        /// 姓名
        /// </summary>
        public string CNname { get; set; }
        /// <summary>
        /// EMAIL
        /// </summary>
        public string Email { get; set; }
        /// <summary>
        /// 級職代號
        /// </summary>
        public string level_code { get; set; }
    }
}
