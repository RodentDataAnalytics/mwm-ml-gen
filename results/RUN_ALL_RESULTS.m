function RUN_ALL_RESULTS( segmentation_configs, classification_configs, labels_path, folds, group_1, group_2, varargin )

    %results_class_weights (segmentation_configs, classification_configs);
    %results_clustering_parameters (segmentation_configs, labels_path);
    %results_confusion_matrix (segmentation_configs, classification_configs, folds);
    results_latency_speed_length (segmentation_configs, group_1, group_2, varargin{:});
    results_strategies_distributions_length (segmentation_configs, classification_configs, group_1, group_2, varargin{:});
    results_strategies_transition_prob (segmentation_configs, classification_configs, group_1, group_2);
    results_transition_counts (segmentation_configs, classification_configs, group_1, group_2);

end

