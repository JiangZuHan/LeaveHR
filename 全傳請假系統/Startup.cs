using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(全傳請假系統.Startup))]
namespace 全傳請假系統
{
    public partial class Startup {
        public void Configuration(IAppBuilder app) {
            ConfigureAuth(app);
        }
    }
}
