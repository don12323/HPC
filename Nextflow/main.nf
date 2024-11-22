#! /usr/bin/env nextflow

version='1.0' // your submitted version should be 1.0
date='05/06/2024'  // update to the date that you last changed this file
author="Don Wijesinghe" // Change to your name


log.info """\
         PHYS4004 workflow assignment
         ============================
         version      : ${version} - ${date}
         author       : ${author}
         --
         run as       : ${workflow.commandLine}
         config files : ${workflow.configFiles}
         container    : ${workflow.containerEngine}:${workflow.container}
         """
         .stripIndent()

// We should wrap our entire process in a workflow function
workflow{
	image_ch = Channel.fromPath(params.image).first()
	bkg_ch = Channel.fromPath(params.bkg).first()
	rms_ch = Channel.fromPath(params.rms).first()
        seeds = Channel.from(5..95).filter{it%5==0}
	ncores = Channel.of(1, 2, 4, 7)
 	
	input_ch = seeds.combine(ncores)
	input_ch.view()
	files_ch = find(input_ch,image_ch,bkg_ch,rms_ch).collect()
        files_ch.view()	

	counted_ch = count(files_ch)
	counted_ch.view()
	plot(counted_ch).view()

}



process find {

        input:
        tuple(val(seed), val(cores))
        // the following images are constant across all versions of this process
        // so just use a 'static' or 'ad hoc' channel
        path image
        path bkg
        path rms

        output:
        file('*.csv')

        // indicate that this process should be allocated a specific number of cores
        cpus "${cores}"
        
        script:
        """
        aegean ${image} --background=${bkg} --noise=${rms} --table=out.csv --seedclip=${seed} --cores=${cores}
        mv out_comp.csv table_${seed}_${cores}.csv
        """
}


process count {

        input:
        // The input should be all the files provided by the 'find' process
        // they are provided through the files_ch channel
        path(files)

        output:
        file('results.csv')

	// don't use singularity for a bunch of bash commands, it's a waste
 	// (and also not all commands work in my container for some reason!)
	container = ''

        // Since we are using bash variables a lot and no nextflow variables
        // we use "shell" instead of "script" so that bash variables don't have
        // to be escaped
        shell:
        '''
        echo "seed,ncores,nsrc" > results.csv
        files=($(ls table*.csv))
        for f in ${files[@]}; do
          seed_cores=($(echo ${f} | tr '_.' ' ' | awk '{print $2 " " $3}'))
          seed=${seed_cores[0]}
          cores=${seed_cores[1]}
          nsrc=$(echo "$(cat ${f}  | wc -l)-1" | bc -l)
          echo "${seed},${cores},${nsrc}" >> results.csv
        done
        '''
}

process plot {
        input:
        path(table)
        output:
        file('*.png') 
	
        cpus 4

        script:
        """
        unique_cores=\$(awk -F',' '{print \$2}' ${table} | tail -n +2 | sort -u)

	echo \${unique_cores[@]} | tr ' ' '\\n' | xargs -n 1 -P 4 -I {} python3 ${params.codedir}/plot_completeness.py --infile ${table} --outfile plot_xargs_{}.png --cores {}
        """
}

//	for cores in \${unique_cores[@]}; do
  //      	python3 ${params.codedir}/plot_completeness.py --infile ${table} --outfile plot\${cores}.png --cores \${cores}
   //     done
//	echo \${unique_cores[@]} | tr ' ' '\\n' | xargs -n 1 -P 4 -I {} python3 ${params.codedir}/plot_completeness.py --infile ${table} --outfile plot_xargs_{}.png --cores {}
