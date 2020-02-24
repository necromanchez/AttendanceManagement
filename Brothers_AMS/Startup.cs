using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Brothers_WMS.Startup))]
namespace Brothers_WMS
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
            app.MapSignalR();
        }
    }
}
