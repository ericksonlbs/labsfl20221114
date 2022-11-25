using dotnet_sfl_tool.Interfaces;
using dotnet_sfl_tool.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace dotnet_sfl_tool.Services
{
    internal class JaguarControlFlowSFLToolService : ISFLToolService
    {
        public SFLModel Convert(string file)
        {
            SFLModel model = new SFLModel()
            {
                Lines = new List<SFLLineModel>()
            };

            XmlSerializer serializer2 = new XmlSerializer(typeof(Models.FlatFaultClassification));
            MemoryStream memStream = new MemoryStream(Encoding.UTF8.GetBytes(File.ReadAllText(file).Replace(" xsi:type=\"lineRequirement\"", "")));
            FlatFaultClassification? obj = serializer2.Deserialize(memStream) as FlatFaultClassification;

            if (obj?.Requirements != null)
                foreach (var item in obj.Requirements)
                {
                    model.Lines.Add(new SFLLineModel()
                    {
                        Class = item.Name,
                        LineNumber = int.Parse(item.Location),
                        Score = double.Parse(item.SuspiciousValue, CultureInfo.InvariantCulture)
                    });
                }

            return model;
        }
    }
}
