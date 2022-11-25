using dotnet_sfl_tool.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal class FactorySFLTool
    {
        private const string GZOLTAR = "-gzoltar.ochiai.ranking.csv";
        private const string FLACOCO = "-flacoco.csv";
        private const string JAGUARCONTROLFLOW = "-jaguar-control-flow.xml";
        private const string JAGUAR2CONTROLFLOW = "-jaguar2.csv";

        internal static ISFLToolService Create(string file)
        {
            if (file.EndsWith(GZOLTAR))
                return new GZoltarSFLToolService();
            else if (file.EndsWith(FLACOCO))
                return new FlacocoSFLToolService();
            else if (file.EndsWith(JAGUARCONTROLFLOW))
                return new JaguarControlFlowSFLToolService();
            else if (file.EndsWith(JAGUAR2CONTROLFLOW))
                return new Jaguar2ControlFlowSFLToolService();
            else
                throw new NotImplementedException($"Interface not implemented to file: {file}");            
        }
    }
}
