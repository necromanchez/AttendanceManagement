using System.Web;
using System.Web.Optimization;

namespace Brothers_WMS
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/Content/js").Include(
                        "~/Content/assets/vendor_components/jquery/dist/jquery.min.js",
                        "~/Content/assets/vendor_components/popper/dist/popper.min.js",
                        "~/Content/assets/vendor_components/bootstrap/dist/js/bootstrap.min.js",
                        "~/Content/assets/vendor_components/jquery-slimscroll/jquery.slimscroll.min.js",
                        "~/Content/assets/vendor_components/fastclick/lib/fastclick.js",
                        "~/Scripts/template.js",
                        "~/Scripts/demo.js",
                        "~/Scripts/resizer.js",
                        "~/Content/Datatable/js/jquery.js",
                        "~/Content/Datatable/js/jquery.dataTables.min.js",
                        "~/Content/Datatable/js/dataTables.bootstrap4.min.js",
                        "~/Content/assets/vendor_components/select2/dist/js/select2.full.js",
                        "~/Content/Datatable/js/datatablebutton.js",
                        "~/Content/plugins/daterangepicker/moment.js"));

            bundles.Add(new ScriptBundle("~/Login/js").Include(
                        "~/Content/assets/vendor_components/jquery/dist/jquery.min.js",
                        "~/Content/assets/vendor_components/popper/dist/popper.min.js",
                        "~/Content/assets/vendor_components/bootstrap/dist/js/bootstrap.min.js",
                        "~/Scripts/respond.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                        "~/Content/assets/vendor_components/bootstrap/dist/css/bootstrap.min.css",
                        "~/Content/assets/vendor_components/bootstrap/dist/css/bootstrap-extend.css",
                        "~/Content/assets/vendor_components/font-awesome/css/font-awesome.min.css",
                        "~/Content/assets/vendor_components/Ionicons/css/ionicons.min.css",
                        "~/Content/css/master_style.css",
                        "~/Content/css/skins/_all-skins.css",
                        "~/Content/assets/vendor_components/select2/dist/css/select2.min.css",
                        "~/Content/css/custom.css"
                        ));


            bundles.Add(new StyleBundle("~/Content/DataTables").Include(
                            "~/Content/Datatable/js/jquery.js",
                            "~/Content/Datatable/js/jquery.dataTables.min.js",
                            "~/Content/Datatable/js/dataTables.bootstrap4.min.js"


            ));

            bundles.Add(new StyleBundle("~/Content/DataTablesCss").Include(
                            "~/Content/Datatable/css/datatables.css",
                            "~/Content/Datatable/css/datatables.min.css",
                            "~/Content/css/datepicker3.css"
            ));
        }
    }
}
