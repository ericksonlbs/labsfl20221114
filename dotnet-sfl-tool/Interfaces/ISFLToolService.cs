using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Interfaces
{
    internal interface ISFLToolService
    {
        public Models.SFLModel Convert(string file);
    }
}
