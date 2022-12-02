using dotnet_sfl_tool.Interfaces;
using dotnet_sfl_tool.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal class GZoltarSFLToolService : ISFLToolService
    {
        private const string IGNORELINE = "name;suspiciousness_value";
        public SFLModel Convert(string file)
        {
            string[] lines = File.ReadAllLines(file);

            SFLModel model = new()
            {
                Lines = new List<SFLLineModel>()
            };

            foreach (var item in lines)
            {
                if (item == IGNORELINE || string.IsNullOrWhiteSpace(item))
                    continue;

                string[] columns = item.Split(';');
                
                var regex = new Regex(Regex.Escape("$"));
                
                model.Lines.Add(new SFLLineModel()
                {
                    Class = regex.Replace($"{columns[0].Split("#")[0]}", ".", 1),
                    LineNumber = int.Parse(columns[0].Split(':')[1]),
                    Score = double.Parse(columns[1], CultureInfo.InvariantCulture)
                });
            }

            return model;
        }
    }
}
