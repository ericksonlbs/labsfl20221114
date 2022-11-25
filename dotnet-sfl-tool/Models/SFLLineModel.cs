using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Models
{
    internal class SFLLineModel
    {
        public string? Class { get; set; }
        public int LineNumber { get; set; }
        public double Score { get; set; }
    }
}
