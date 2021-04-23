using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace azure_pub_sub
{
    public static class Subscriber_2
    {
        [FunctionName("Subscriber_2")]

        public static void Run([ServiceBusTrigger("az-pubsub-topic", "az-pubsub-subscription-2", Connection = "CONNECTION_STRING")]string topicItem, ILogger log)
        {
            log.LogInformation("Subscriber-2");
            log.LogInformation($"{topicItem}");
        }
    }
}
