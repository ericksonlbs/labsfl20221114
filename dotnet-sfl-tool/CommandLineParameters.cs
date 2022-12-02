using CommandLine;

namespace dotnet_sfl_tool
{
    internal class CommandLineParameters
    {
        [Option('p', "inputPath", Required = true, HelpText = "Set path input results.")]
        public string path { get; set; }

        [Option('w', "outputPath", Required = true, HelpText = "Set path output results.")]
        public string output { get; set; }

        [Option('o', "order", Required = true, HelpText = "Set order (class or score).")]
        public OrderEnum order { get; set; }
    }

    internal enum OrderEnum
    {
        /// <summary>
        /// By Class        
        /// </summary>
        @class,
        /// <summary>
        /// By Score
        /// </summary>
        score
    }
}
