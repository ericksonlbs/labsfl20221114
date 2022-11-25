using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace dotnet_sfl_tool.Models
{
    [System.SerializableAttribute()]    
    public class FlatFaultClassification
    {
        /// <remarks/>
        [XmlElement("requirements")]
        public FlatFaultClassificationRequirements[] Requirements { get; set; }
    }

    /// <remarks/>
    [System.SerializableAttribute()]
    public partial class FlatFaultClassificationRequirements
    {
        /// <remarks/>
        [XmlAttribute("location")]
        public string Location { get; set; }


        /// <remarks/>
        [XmlAttribute("name")]
        public string Name { get; set; }

        /// <remarks/>
        [XmlAttribute("suspicious-value")]
        public string SuspiciousValue { get; set; }
    }


}
