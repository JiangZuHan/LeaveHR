using System.Xml;
using System.Configuration;
using System.Web;
using System.Text;

namespace HRS.Common
{
    public class Param
    {
        /// <summary>
        /// 加密编码
        /// </summary>
        public static string EncCode = ConfigurationManager.AppSettings["EncCode"];
        public static byte[] Iv_64 = Encoding.UTF8.GetBytes(EncCode);
        public static byte[] Key_64 = Encoding.UTF8.GetBytes(EncCode);
    }
}
