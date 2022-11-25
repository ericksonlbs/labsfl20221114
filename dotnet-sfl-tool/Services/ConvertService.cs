using dotnet_sfl_tool.Interfaces;
using dotnet_sfl_tool.Models;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace dotnet_sfl_tool.Services
{
    internal class ConvertService : IConvertService
    {
        private readonly CommandLineParameters parameters;
        private readonly ISFLService sFLService;
        private readonly ILogger<ConvertService> logger;
        private const string EXECUTION = "-execution.csv";

        public ConvertService(CommandLineParameters parameters, ISFLService SFLService, ILogger<ConvertService> logger)
        {
            this.parameters = parameters;
            sFLService = SFLService;
            this.logger = logger;
            //if (string.IsNullOrWhiteSpace(parameters.path))
            //{
            //    ArgumentNullException argumentNullException = new (nameof(parameters.path));
            //    throw argumentNullException;
            //}
        }

        public Task Run()
        {
            List<string> files = new List<string>();
            files.AddRange(Directory.GetFiles(parameters.path, "*.csv", SearchOption.TopDirectoryOnly));
            files.AddRange(Directory.GetFiles(parameters.path, "*.xml", SearchOption.TopDirectoryOnly));

            foreach (string file in files)
            {
                ISFLToolService tool;

                if (file.EndsWith(EXECUTION))
                    continue;

                try
                {
                    tool = FactorySFLTool.Create(file);
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, ex.Message);

                    continue;
                }

                SFLModel model = tool.Convert(file);

                string filename = Path.GetFileNameWithoutExtension(file);

                if (!Directory.Exists(parameters.output))
                    Directory.CreateDirectory(parameters.output);

                string fileoutput = Path.Combine(parameters.output, $"{filename}.csv");
                
                if (File.Exists(fileoutput))
                    File.Delete(fileoutput);

                sFLService.WriteFile(model, fileoutput);
            }
            return Task.CompletedTask;
        }
    }
}
