using dotnet_sfl_tool.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal class SFLService : ISFLService
    {
        public void WriteFile(SFLModel model, string outputFile)
        {
            IOrderedEnumerable<SFLLineModel> lines = model.Lines.OrderByDescending(c => c.Score).ThenBy(c => c.Class).ThenBy(c => c.LineNumber);
            List<string> stringLines = new List<string>();

            foreach (var item in lines)
                if (item.Score > 0)
                    stringLines.Add(ConvertLine(item));

            File.AppendAllLines(outputFile, stringLines);
        }

        private string ConvertLine(SFLLineModel model)
        {
            return $"{model.Class},{model.LineNumber},{model.Score.ToString("0.000000", CultureInfo.InvariantCulture)}";
        }
    }
}
