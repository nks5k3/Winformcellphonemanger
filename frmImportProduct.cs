﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
namespace DoAnWinformBanDienThoai
{
    public partial class frmImportProduct : Form
    {
        private string _pName;
       
        private string _pNewTime;
        private int _pGuarantee;
        private string _pMake;
        public frmImportProduct()
        {
            InitializeComponent();
        }

        public frmImportProduct(string Name  )
        {
           
            _pName = Name;
            Console.WriteLine(_pName);
        }

        private void ucBrand1_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {
            Console.WriteLine(123456);
        }
    }
}
