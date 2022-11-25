using dotnet_sfl_tool.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal interface ISFLService 
    {
        public void WriteFile(SFLModel model, string outputFile);
    }
}
