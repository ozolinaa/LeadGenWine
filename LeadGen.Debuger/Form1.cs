using LeadGen.Code.Business;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LeadGen.Debuger
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            SqlConnection DBLGcon;
            DBLGcon = new SqlConnection(Properties.Settings.Default.DBConStrLeadGenLocal);
            DBLGcon.Open();

            //LeadPermission p = new LeadPermission() { termIDs = new List<long> { 9, 21 } };
            //var rrr = p.AddRequestToDB(DBLGcon, 27);
            //rrr = rrr;

            DBLGcon.Close();
            DBLGcon.Dispose();
        }
    }
}
