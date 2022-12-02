using CommandLine;
using dotnet_sfl_tool.Models;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal class SFLService : ISFLService
    {
        private readonly CommandLineParameters parameters;

        public SFLService(CommandLineParameters parameters)
        {
            this.parameters = parameters;
        }

        public void WriteFile(SFLModel model, string outputFile)
        {
            if (model is null)
                throw new ArgumentNullException(nameof(model));
            if (model.Lines is null)
                throw new ArgumentNullException(nameof(model.Lines));

            List<string> stringLines = new();

            IOrderedEnumerable<SFLLineModel> lines;
            switch (parameters.order)
            {
                case OrderEnum.@class:
                    lines = model.Lines
                        .OrderBy(c => c.Class)
                        .ThenBy(c => c.LineNumber)
                        .ThenByDescending(c => c.Score);
                    break;
                default:
                case OrderEnum.score:
                    lines = model.Lines
                        .OrderByDescending(c => c.Score)
                        .ThenBy(c => c.Class)
                        .ThenBy(c => c.LineNumber);
                    break;
            }

            foreach (var item in lines)
                if (item.Score > 0)
                    stringLines.Add($"{item.Class},{item.LineNumber},{item.Score.ToString("0.000000", CultureInfo.InvariantCulture)}");


            File.AppendAllLines(outputFile, stringLines);
        }
    }
}
