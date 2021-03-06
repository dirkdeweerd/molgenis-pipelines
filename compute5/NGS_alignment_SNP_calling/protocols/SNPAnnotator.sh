#MOLGENIS walltime=35:59:00 mem=4gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffSNPCallsHtml
#string snpEffSnpsVcf
#string snpEffSNPGenesTxt
#string indexFile
#string baitIntervals
#string variantVcf
#string variantAnnotatorOutputVcf
#list externalSampleID
#string tmpDataDir
#string project
#string GATKVersion
#string SnpEffVersion
#string JavaVersion

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "snpEffCallsHtml: ${snpEffSNPCallsHtml}"
echo "snpEffCallsVcf: ${snpEffSnpsVcf}"
echo "snpEffGenesTxt: ${snpEffSNPGenesTxt}"

sleep 10

makeTmpDir ${snpEffSNPCallsHtml}
tmpSnpEffSNPCallsHtml=${MC_tmpFile}

makeTmpDir ${snpEffSnpsVcf}
tmpsnpEffSnpsVcf=${MC_tmpFile}

makeTmpDir ${snpEffSNPGenesTxt}
tmpSnpEffSNPGenesTxt=${MC_tmpFile}

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

for externalID in "${externalSampleID[@]}"
do
        array_contains SAMPLES "$externalID" || SAMPLES+=("$externalID")    # If bamFile does not exist in array add it
done

for sample in "${SAMPLES[@]}"
do
  getFile ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam
  getFile ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bai
  
  echo "sample: ${sample}"		
  INPUTS+=("-I ${intermediateDir}/${sample}.merged.dedup.realigned.bqsr.bam")
done


#Load GATK module
${stage} jdk/${JavaVersion}
${stage} GATK/${GATKVersion}
${stage} snpEff/${SnpEffVersion}
${checkStage}

java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/GenomeAnalysisTK.jar \
-T VariantAnnotator \
-R ${indexFile} \
${INPUTS[@]} \
-A SnpEff \
-A AlleleBalance \
-A BaseCounts \
-A BaseQualityRankSumTest \
-A ChromosomeCounts \
-A Coverage \
-A FisherStrand \
-A LikelihoodRankSumTest \
-A HaplotypeScore \
-A MappingQualityRankSumTest \
-A MappingQualityZeroBySample \
-A ReadPosRankSumTest \
-A RMSMappingQuality \
-A QualByDepth \
-A VariantType \
-A AlleleBalanceBySample \
-A DepthPerAlleleBySample \
-A SpanningDeletions \
--disable_auto_index_creation_and_locking_when_reading_rods \
-D /gcc/resources/b37/snp/dbSNP/dbsnp_137.b37.vcf \
--variant ${variantVcf} \
--snpEffFile ${snpEffSnpsVcf} \
-L ${baitIntervals} \
-o ${variantAnnotatorOutputVcf} \
-nt 8
