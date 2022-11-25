using dotnet_sfl_tool.Interfaces;
using dotnet_sfl_tool.Models;
using System.Globalization;

namespace dotnet_sfl_tool.Services
{
    internal class Jaguar2ControlFlowSFLToolService : ISFLToolService
    {
        public SFLModel Convert(string file)
        {
            string[] lines = File.ReadAllLines(file);

            SFLModel model = new()
            {
                Lines = new List<SFLLineModel>()
            };

            foreach (var item in lines)
            {
                if (string.IsNullOrWhiteSpace(item))
                    continue;

                string[] columns = item.Split(',');

                model.Lines.Add(new SFLLineModel()
                {
                    Class = columns[0].Replace("/", "."),
                    LineNumber = int.Parse(columns[1]),
                    Score = double.Parse(columns[6], CultureInfo.InvariantCulture)
                });
            }

            return model;
        }
    }
}
